import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      String? orderDirection,
      String? searchQuery}) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };

    if (sort != null) {
      queryParameters['orderBy'] = sort;
    }
    if (orderDirection != null) {
      queryParameters['orderDirection'] = orderDirection;
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

  /// Returns the raw JSON map for a recipe (used for merge-then-PUT updates).
  Future<Map<String, dynamic>> getRecipeRaw(String slug) async {
    final response = await _dio.get('api/recipes/$slug');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<FoodResponse> getFoods({int page = 1, int perPage = 10}) async {
    final response = await _dio.get(
      'api/foods',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return FoodResponse.fromJson(response.data);
  }

  /// Searches for a food by exact name (case-insensitive).
  /// Returns the food if found, null otherwise.
  Future<Food?> searchFoodByName(String name) async {
    try {
      // Search with the food name as query
      final response = await _dio.get(
        'api/foods',
        queryParameters: {
          'search': name,
          'per_page': 50,
        },
      );
      final foodResponse = FoodResponse.fromJson(response.data);

      // Find exact match (case-insensitive)
      final normalizedName = name.toLowerCase().trim();
      for (final food in foodResponse.items) {
        if (food.name.toLowerCase().trim() == normalizedName) {
          debugPrint('searchFoodByName: Found exact match for "$name" -> ${food.id}');
          return food;
        }
      }
      debugPrint('searchFoodByName: No exact match found for "$name"');
      return null;
    } catch (e) {
      debugPrint('searchFoodByName error: $e');
      return null;
    }
  }

  Future<Food> createFood(Food food) async {
    final jsonData = food.toJson();
    debugPrint('DEBUG: POST /api/foods - Payload: $jsonData');
    try {
      final response = await _dio.post(
        'api/foods',
        data: jsonData,
      );
      debugPrint('DEBUG: POST /api/foods - Response status: ${response.statusCode}');
      debugPrint('DEBUG: POST /api/foods - Response data: ${response.data}');
      return Food.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('DEBUG: POST /api/foods - DioException: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('DEBUG: POST /api/foods - Error: $e');
      rethrow;
    }
  }

  Future<void> deleteFood(String foodId) async {
    await _dio.delete('api/foods/$foodId');
  }

  Future<void> deleteRecipe(String slug) async {
    await _dio.delete('api/recipes/$slug');
  }

  /// POST /api/recipes – creates a recipe stub, returns the slug as String.
  Future<String> createRecipe(String name) async {
    debugPrint('POST /api/recipes with name: $name');
    final response = await _dio.post(
      'api/recipes',
      data: {'name': name},
    );
    // Mealie returns the slug as a plain string (possibly quoted)
    final slug = response.data.toString().replaceAll('"', '').trim();
    debugPrint('POST /api/recipes returned slug: $slug');
    return slug;
  }

  /// PUT /api/recipes/{slug} – updates the recipe with full details.
  Future<Recipe> updateRecipe(String slug, Map<String, dynamic> data) async {
    debugPrint('PUT /api/recipes/$slug');
    final response = await _dio.put(
      'api/recipes/$slug',
      data: data,
    );
    debugPrint('PUT /api/recipes/$slug response status: ${response.statusCode}');
    return Recipe.fromJson(response.data);
  }

  /// Fetches all user ratings/favorites at once via GET /api/users/{id}/favorites.
  /// Returns a Map<recipeId, isFavorite>.
  Future<Map<String, bool>> getUserFavorites() async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) return {};
    try {
      final response = await _dio.get('api/users/$userId/favorites');
      final ratings = response.data['ratings'] as List? ?? [];
      return {
        for (final r in ratings)
          if (r['recipeId'] != null)
            r['recipeId'].toString(): (r['isFavorite'] as bool?) ?? false,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return {};
      rethrow;
    } catch (_) {
      return {};
    }
  }

  /// Fetches the user's current rating entry (rating + isFavorite) by recipe slug.
  /// Uses GET /api/users/self/ratings/{recipe_id} where recipe_id is the UUID.
  /// Returns an empty map when no entry exists yet (404 is treated as empty).
  Future<Map<String, dynamic>> _getUserRatingEntry(String slug) async {
    // First we need the recipe ID (UUID) from the slug
    try {
      final recipe = await getRecipe(slug);
      final recipeId = recipe.id;

      debugPrint('_getUserRatingEntry: slug=$slug, recipeId=$recipeId');

      // Use the /api/users/self/ratings/{recipe_id} endpoint
      final response = await _dio.get('api/users/self/ratings/$recipeId');
      debugPrint('_getUserRatingEntry response: ${response.data}');
      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      debugPrint('_getUserRatingEntry DioException: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 404) return {};
      rethrow;
    } catch (e) {
      debugPrint('_getUserRatingEntry error: $e');
      return {};
    }
  }

  /// Fetches the user's current rating entry by recipe ID (UUID).
  Future<Map<String, dynamic>> _getUserRatingEntryById(String recipeId) async {
    try {
      debugPrint('_getUserRatingEntryById: recipeId=$recipeId');
      final response = await _dio.get('api/users/self/ratings/$recipeId');
      debugPrint('_getUserRatingEntryById response: ${response.data}');
      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      debugPrint('_getUserRatingEntryById DioException: ${e.response?.statusCode}');
      if (e.response?.statusCode == 404) return {};
      rethrow;
    } catch (e) {
      debugPrint('_getUserRatingEntryById error: $e');
      return {};
    }
  }

  /// Sets user rating – preserves the existing isFavorite value.
  Future<void> setRating(String slug, double rating) async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('setRating: No userId cached, cannot set rating');
      return;
    }
    final current = await _getUserRatingEntry(slug);
    debugPrint('POST /api/users/$userId/ratings/$slug – rating=$rating, isFavorite=${current['isFavorite']}');
    await _dio.post(
      'api/users/$userId/ratings/$slug',
      data: {
        'rating': rating,
        'isFavorite': current['isFavorite'],
      },
    );
    debugPrint('Rating set successfully for $slug');
  }

  /// Returns the user's favorite status for a recipe by slug.
  Future<bool> getFavoriteStatus(String slug) async {
    final entry = await _getUserRatingEntry(slug);
    final isFavorite = (entry['isFavorite'] as bool?) ?? false;
    debugPrint('getFavoriteStatus($slug): $isFavorite');
    return isFavorite;
  }

  /// Returns the user's favorite status for a recipe by ID (UUID).
  Future<bool> getFavoriteStatusById(String recipeId) async {
    final entry = await _getUserRatingEntryById(recipeId);
    final isFavorite = (entry['isFavorite'] as bool?) ?? false;
    debugPrint('getFavoriteStatusById($recipeId): $isFavorite');
    return isFavorite;
  }

  /// Sets the favorite flag – preserves the existing rating value.
  Future<void> setFavorite(String slug, {required bool isFavorite}) async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('setFavorite: No userId cached');
      return;
    }
    final current = await _getUserRatingEntry(slug);
    debugPrint('POST /api/users/$userId/ratings/$slug – isFavorite=$isFavorite, rating=${current['rating']}');
    await _dio.post(
      'api/users/$userId/ratings/$slug',
      data: {
        'rating': current['rating'],
        'isFavorite': isFavorite,
      },
    );
  }

  /// Fetches the current user's profile and caches the userId.
  /// Returns the userId on success, throws on failure.
  Future<String> fetchAndCacheUserId() async {
    final response = await _dio.get('api/users/self');
    final userId = response.data['id']?.toString() ?? '';
    if (userId.isNotEmpty) {
      await _tokenStorage.saveUserId(userId);
    }
    return userId;
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
