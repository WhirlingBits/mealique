import 'package:dio/dio.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/models/recipes_model.dart';
import '../remote/recipes_api.dart';

class RecipeRepository {
  final RecipesApi _api;
  final TokenStorage _tokenStorage;

  RecipeRepository() 
      : _api = RecipesApi(),
        _tokenStorage = TokenStorage();

  Future<List<Recipe>> getRecipes(
      {int page = 1,
      int perPage = 15,
      String? sort,
      String? searchQuery}) async {
    final token = await _tokenStorage.getToken();

    // --- DEMO DATA LOGIC ---
    if (token == AppConstants.demoToken) {
      return _getDemoRecipes();
    }
    // --- END DEMO DATA LOGIC ---

    try {
      final response = await _api.getRecipes(
          page: page, perPage: perPage, sort: sort, searchQuery: searchQuery);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['items'] is List) {
          final items = data['items'] as List;
          return items.map((item) => Recipe.fromJson(item)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Handle unauthorized access
      }
      rethrow;
    }
  }

  Future<Recipe> getRecipe(String slug) async {
     final token = await _tokenStorage.getToken();
    // --- DEMO DATA LOGIC ---
    if (token == AppConstants.demoToken) {
      final demoRecipe = _getDemoRecipes().firstWhere((r) => r.slug == slug, 
        orElse: () => _getDemoRecipes().first);
      return Future.value(demoRecipe);
    }
    // --- END DEMO DATA LOGIC ---
    return _api.getRecipe(slug);
  }

  // Helper for demo data
  List<Recipe> _getDemoRecipes() {
    return [
      Recipe(
        id: '1',
        name: 'Pasta Bolognese',
        slug: 'pasta-bolognese',
        totalTime: '45m',
        servings: 4,
        description: 'A classic Italian dish, perfect for the whole family.',
        ingredients: [
          RecipeIngredient(note: '500g minced meat', quantity: 500),
          RecipeIngredient(note: '1 can of tomatoes', quantity: 1),
          RecipeIngredient(note: '2 onions', quantity: 2),
          RecipeIngredient(note: '500g spaghetti', quantity: 500),
        ],
        instructions: [
          RecipeInstruction(text: 'Sauté onions and minced meat.'),
          RecipeInstruction(text: 'Add tomatoes and simmer for 30 minutes.'),
          RecipeInstruction(text: 'Cook spaghetti and serve with the sauce.'),
        ]
      ),
      Recipe(
        id: '2',
        name: 'Chicken Curry',
        slug: 'chicken-curry',
        totalTime: '30m',
        servings: 3,
         description: 'A quick and delicious curry with chicken and coconut milk.',
        ingredients: [
          RecipeIngredient(note: '400g chicken breast', quantity: 400),
          RecipeIngredient(note: '1 can of coconut milk', quantity: 1),
          RecipeIngredient(note: '2 tbsp curry paste', quantity: 2),
        ],
        instructions: [
          RecipeInstruction(text: 'Sauté the chicken.'),
          RecipeInstruction(text: 'Add curry paste and coconut milk.'),
          RecipeInstruction(text: 'Simmer for 15 minutes and serve with rice.'),
        ]
      ),
    ];
  }
}
