import 'package:dio/dio.dart';
import 'package:mealique/data/remote/dio_client.dart';
import 'package:mealique/models/food_model.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/models/shopping_item_model.dart';
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

  Future<FoodResponse> getFoods({int page = 1, int perPage = 10}) async {
    final response = await _dio.get(
      'api/foods',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return FoodResponse.fromJson(response.data);
  }

  Future<Food> createFood(Food food) async {
    final response = await _dio.post(
      'api/foods',
      data: food.toJson(),
    );
    return Food.fromJson(response.data);
  }

  Future<void> deleteFood(String foodId) async {
    await _dio.delete('api/foods/$foodId');
  }

  Future<List<ShoppingItemUnit>> getUnits() async {
    try {
      final response = await _dio.get('api/units');
      // Some endpoints return list directly, others paginate.
      // Assuming list based on typical Mealie endpoints for simple resources like units.
      // If paginated, it would have 'items' key.
      if (response.data is List) {
        return (response.data as List).map((e) => ShoppingItemUnit.fromJson(e)).toList();
      } else if (response.data['items'] is List) {
        return (response.data['items'] as List).map((e) => ShoppingItemUnit.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
