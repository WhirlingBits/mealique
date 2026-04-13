import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/data/local/token_storage.dart';

class AuthApi {
  final Dio _dio;

  AuthApi() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    // Note: We are not including the central error interceptor from DioClient here
    // because we need to handle the login error case specifically.
  }

  Future<String?> login(String baseUrl, String username, String password) async {
    _dio.options.baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    try {
      final response = await _dio.post(
        'api/auth/token',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        return response.data['access_token'] as String?;
      }
      return null;
    } on DioException {
      // Special handling for login: We don't want to retry automatically.
      // We just rethrow and let the UI handle the failure.
      rethrow;
    }
  }

  /// Attempt to get a new token using stored credentials.
  /// Returns the new token on success, null if refresh is not possible.
  Future<String?> refreshToken() async {
    final storage = TokenStorage();

    // Check if this is a demo token - demo tokens don't need refresh
    final currentToken = await storage.getToken();
    final serverUrl = await storage.getServerUrl();

    debugPrint('AuthApi.refreshToken: currentToken=${currentToken?.substring(0, (currentToken.length).clamp(0, 20))}..., serverUrl=$serverUrl');

    // Demo mode check - if token is demo token OR server is demo server, stay in demo mode
    if (currentToken == AppConstants.demoToken || serverUrl == AppConstants.demoServerUrl) {
      debugPrint('AuthApi.refreshToken: Demo mode detected, returning demo token');
      return AppConstants.demoToken;
    }

    final username = await storage.getUsername();
    final password = await storage.getPassword();

    debugPrint('AuthApi.refreshToken: username=$username, hasPassword=${password != null && password.isNotEmpty}');

    // Don't attempt refresh with empty credentials
    if (serverUrl == null ||
        serverUrl.isEmpty ||
        username == null ||
        username.isEmpty ||
        password == null ||
        password.isEmpty) {
      debugPrint('AuthApi.refreshToken: Missing credentials, cannot refresh');
      return null; // No valid stored credentials, can't refresh
    }

    try {
      debugPrint('AuthApi.refreshToken: Attempting login to $serverUrl');
      final newToken = await login(serverUrl, username, password);
      if (newToken != null) {
        await storage.saveToken(newToken);
        debugPrint('AuthApi.refreshToken: Successfully refreshed token');
      }
      return newToken;
    } catch (e) {
      debugPrint('AuthApi.refreshToken: Failed to refresh: $e');
      return null; // Refresh failed (wrong password, server down, etc.)
    }
  }
}
