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
        switch (err.response?.statusCode) {
          case 401:
            apiException = UnauthorizedException();
            break;
          case 404:
            apiException = NotFoundException(message: err.response?.data?['detail'] ?? 'Not found');
            break;
          case 500:
          case 502:
          case 503:
            apiException = ServerException(
                statusCode: err.response?.statusCode,
                message: err.response?.data?['detail'] ?? 'Server error');
            break;
          default:
            apiException = BadRequestException(
                statusCode: err.response?.statusCode,
                message: err.response?.data?['detail'] ?? 'Bad request');
            break;
        }
        break;
      default:
        apiException = ApiException(message: 'An unexpected error occurred');
        break;
    }

    // Replace the original DioException with one that contains the custom exception
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
