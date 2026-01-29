import 'package:dio/dio.dart';
import '../local/token_storage.dart';

class RecipesApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  RecipesApi({required String baseUrl})
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

  /// Fetches a paginated list of recipes from the Mealie API.
  Future<Response> getRecipes({int page = 1, int perPage = 15}) async {
    try {
      final response = await _dio.get(
        '/api/recipes',
        queryParameters: {
          'page': page,
          'perPage': perPage,
        },
      );
      return response;
    } catch (e) {
      // Re-throw the error to be handled by the caller, e.g., for auth checks.
      rethrow;
    }
  }
}
