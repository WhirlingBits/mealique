import 'package:dio/dio.dart';
import '../local/token_storage.dart';


class MealsApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  MealsApi ({required String baseUrl})
      : _tokenStorage = TokenStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
        )) {
    // Add interceptor for auth tokens
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }
}
