import 'package:dio/dio.dart';
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
    final serverUrl = await storage.getServerUrl();
    final username = await storage.getUsername();
    final password = await storage.getPassword();

    if (serverUrl == null || username == null || password == null) {
      return null; // No stored credentials, can't refresh
    }

    try {
      final newToken = await login(serverUrl, username, password);
      if (newToken != null) {
        await storage.saveToken(newToken);
      }
      return newToken;
    } catch (_) {
      return null; // Refresh failed (wrong password, server down, etc.)
    }
  }
}
