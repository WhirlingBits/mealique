import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/auth_api.dart';
import 'api_exceptions.dart';

/// Global navigator key used to redirect to login on unrecoverable auth failures.
/// Must be assigned to the MaterialApp's navigatorKey.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DioClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      RetryInterceptor(dio: dio),
      TokenRefreshInterceptor(dio: dio),
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
    String? extractDetail(dynamic data) {
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
        if (data['message'] is String) return data['message'];
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
        apiException = NetworkException(err.message ?? 'Please check your internet connection.');
        break;
      case DioExceptionType.badResponse:
        final detail = extractDetail(err.response?.data);
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
        apiException = ApiException(message: err.message ?? 'An unexpected error occurred');
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

/// Interceptor that automatically refreshes the JWT token when a 401 is received.
/// It re-authenticates using stored credentials and retries the original request.
/// If the refresh fails, the user is redirected to the login screen.
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();
  final AuthApi _authApi = AuthApi();

  // Prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;
  final _pendingRequests = <({ErrorInterceptorHandler handler, RequestOptions options})>[];

  TokenRefreshInterceptor({required this.dio});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 responses
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't try to refresh if this was already a retry after refresh
    if (err.requestOptions.extra['is_retry_after_refresh'] == true) {
      return handler.next(err);
    }

    // Don't try to refresh for demo accounts
    final currentToken = await _tokenStorage.getToken();
    if (currentToken == AppConstants.demoToken) {
      return handler.next(err);
    }

    // If already refreshing, queue this request
    if (_isRefreshing) {
      _pendingRequests.add((handler: handler, options: err.requestOptions));
      return;
    }

    _isRefreshing = true;

    try {
      final newToken = await _authApi.refreshToken();

      if (newToken != null) {
        // Update the authorization header and retry the failed request
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        err.requestOptions.extra['is_retry_after_refresh'] = true;

        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }

        // Retry all queued requests with the new token
        for (final pending in _pendingRequests) {
          pending.options.headers['Authorization'] = 'Bearer $newToken';
          pending.options.extra['is_retry_after_refresh'] = true;
          try {
            final response = await dio.fetch(pending.options);
            pending.handler.resolve(response);
          } on DioException catch (retryError) {
            pending.handler.next(retryError);
          }
        }
      } else {
        // Refresh failed — credentials invalid or missing.
        // Reject the original request and all pending ones.
        handler.next(err);
        for (final pending in _pendingRequests) {
          pending.handler.next(err);
        }

        // Navigate to login screen
        _redirectToLogin();
      }
    } catch (_) {
      handler.next(err);
      for (final pending in _pendingRequests) {
        pending.handler.next(err);
      }
      _redirectToLogin();
    } finally {
      _pendingRequests.clear();
      _isRefreshing = false;
    }
  }

  void _redirectToLogin() {
    // Clear stored token since it's no longer valid
    _tokenStorage.clearAll();

    // Use the global navigator key to navigate to login
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }
}
