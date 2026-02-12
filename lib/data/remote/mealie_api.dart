import 'package:dio/dio.dart';
import 'package:mealique/data/local/token_storage.dart';

class MealieApi {
  final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();

  MealieApi({required String baseUrl})
      : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/auth/token',
        data: {
          'username': email,
          'password': password,
        },
        // Mealie API expects form data for token authentication
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['access_token'] as String;
        await _tokenStorage.saveToken(token);
        // Also save the server url for future sessions
        await _tokenStorage.saveServerUrl(dio.options.baseUrl);
        return true;
      }
      return false;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSelf() async {
    try {
      final response = await dio.get('/api/users/me');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Handle DioError or other exceptions
      print('Failed to get self: $e');
      return null;
    }
  }
}
