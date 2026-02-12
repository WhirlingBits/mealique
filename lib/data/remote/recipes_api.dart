import 'package:dio/dio.dart';
import 'package:mealique/data/remote/dio_client.dart';
import 'package:mealique/models/recipes_model.dart';
import '../local/token_storage.dart';

class RecipesApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  RecipesApi({String? baseUrl})
      : _tokenStorage = TokenStorage(),
        _dio = DioClient.createDio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.baseUrl.isEmpty) {
          final serverUrl = await _tokenStorage.getServerUrl();
          if (serverUrl != null && serverUrl.isNotEmpty) {
            options.baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
          }
        }

        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
    ));
  }

  Future<Response> getRecipes(
      {int page = 1,
      int perPage = 15,
      String? sort,
      String? searchQuery}) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };

    if (sort != null) {
      queryParameters['sort'] = sort;
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParameters['search'] = searchQuery;
    }

    final response = await _dio.get(
      'api/recipes',
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Recipe> getRecipe(String slug) async {
    final response = await _dio.get('api/recipes/$slug');
    return Recipe.fromJson(response.data);
  }
}
