import 'package:dio/dio.dart';
import 'api_exceptions.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      RetryInterceptor(dio: dio),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}

/// Interceptor to handle API errors and convert them into custom exceptions.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException apiException;

    // Helper to extract detail message from response data
    String? _extractDetail(dynamic data) {
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String) return detail;
        // FastAPI/Pydantic validation errors return detail as a List
        if (detail is List && detail.isNotEmpty) {
          return detail.map((e) {
            if (e is Map<String, dynamic>) {
              final loc = (e['loc'] as List?)?.join(' > ') ?? '';
              final msg = e['msg'] ?? '';
              return '$loc: $msg';
            }
            return e.toString();
          }).join('; ');
        }
        if (detail != null) return detail.toString();
        // Mealie error format: {message: "...", error: true, exception: "..."}
        if (data['message'] is String) return data.toString();
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      return null;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = NetworkException('Connection timeout');
        break;
      case DioExceptionType.unknown:
        apiException = NetworkException('Please check your internet connection.');
        break;
      case DioExceptionType.badResponse:
        final detail = _extractDetail(err.response?.data);
        switch (err.response?.statusCode) {
          case 401:
            apiException = UnauthorizedException();
            break;
          case 404:
            apiException = NotFoundException(message: detail ?? 'Not found');
            break;
          case 422:
            apiException = BadRequestException(
                statusCode: 422,
                message: detail ?? err.response?.data?.toString() ?? 'Validation error');
            break;
          case 500:
          case 502:
          case 503:
            apiException = ServerException(
                statusCode: err.response?.statusCode,
                message: detail ?? 'Server error');
            break;
          default:
            apiException = BadRequestException(
                statusCode: err.response?.statusCode,
                message: detail ?? 'Bad request');
            break;
        }
        break;
      default:
        apiException = ApiException(message: 'An unexpected error occurred');
        break;
    }

    // Replace the original DioException with one that contains the custom exception
    // but preserve the original response for debugging
    final newErr = err.copyWith(error: apiException);
    return handler.next(newErr);
  }
}

/// Interceptor to automatically retry requests on network-related failures.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      int retryCount = err.requestOptions.extra['retry_count'] ?? 0;
      if (retryCount < maxRetries) {
        retryCount++;
        err.requestOptions.extra['retry_count'] = retryCount;

        // Exponential back-off delay
        await Future.delayed(Duration(seconds: retryCount * 2));

        try {
          // Re-run the request.
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          // If the retry also fails, pass the error to the next interceptor.
          return handler.next(e);
        }
      }
    }
    // If we shouldn't retry, or retries are exhausted, pass the error along.
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown;
  }
}
