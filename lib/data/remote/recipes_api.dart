import 'package:dio/dio.dart';
import '../local/token_storage.dart';

class RecipesApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  RecipesApi({String? baseUrl})
      : _tokenStorage = TokenStorage(),
        _dio = Dio(BaseOptions(
          // If no URL has been provided, we start with an empty list.
          // The interceptor then places the URL before the request.
          baseUrl: baseUrl ?? '',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        )) {
    // Add interceptor for auth tokens and dynamic server URLs
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Load server URL (if not set or empty in the constructor)
        if (options.baseUrl.isEmpty) {
          final serverUrl = await _tokenStorage.getServerUrl();
          if (serverUrl != null && serverUrl.isNotEmpty) {
            // Ensure that the URL is formatted correctly (slash at the end).
            options.baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
          }
        }

        // 2. load Auth Token
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
    ));
  }

  /// Fetches a paginated list of recipes from the Mealie API.
  Future<Response> getRecipes(
      {int page = 1, int perPage = 15, String? sort}) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };

      if (sort != null) {
        queryParameters['sort'] = sort;
      }

      final response = await _dio.get(
        'api/recipes',
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      // Re-throw the error to be handled by the caller, e.g., for auth checks.
      rethrow;
    }
  }
}
