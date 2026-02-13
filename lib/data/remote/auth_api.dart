import 'package:dio/dio.dart';
import 'package:mealique/data/remote/dio_client.dart';

class AuthApi {
  final Dio _dio;

  AuthApi() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
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
}
