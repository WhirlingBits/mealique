
import 'package:dio/dio.dart';

import '../../models/recipes_model.dart';
import '../remote/recipes_api.dart';

class RecipeRepository {
  final RecipesApi _api;

  RecipeRepository() : _api = RecipesApi();

  Future<List<Recipe>> getRecipes(
      {int page = 1, int perPage = 15, String? sort}) async {
    try {
      final response = await _api.getRecipes(page: page, perPage: perPage, sort: sort);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['items'] is List) {
          final items = data['items'] as List;
          return items.map((item) => Recipe.fromJson(item)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      // Handle Dio-specific errors, e.g., for auth checks.
      if (e.response?.statusCode == 401) {
        // Handle unauthorized access
      }
      rethrow;
    }
  }
}
