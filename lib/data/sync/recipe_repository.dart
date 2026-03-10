import 'package:flutter/foundation.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/core/utils/offline_helper.dart';
import 'package:mealique/data/local/recipe_storage.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/models/food_model.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/models/shopping_item_model.dart';
import '../remote/recipes_api.dart';

class RecipeRepository {
  final RecipesApi _api;
  final RecipeStorage _storage;
  final TokenStorage _tokenStorage;

  RecipeRepository()
      : _api = RecipesApi(),
        _storage = RecipeStorage(),
        _tokenStorage = TokenStorage();

  Future<List<Recipe>> getRecipes(
      {int page = 1,
      int perPage = 15,
      String? sort,
      String? orderDirection,
      String? searchQuery}) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoRecipes();
    }

    return withOfflineFallbackSimple<List<Recipe>>(
      apiCall: () async {
        final response = await _api.getRecipes(
            page: page,
            perPage: perPage,
            sort: sort,
            orderDirection: orderDirection,
            searchQuery: searchQuery);
        if (response.statusCode == 200) {
          final data = response.data;
          if (data != null && data['items'] is List) {
            final items = data['items'] as List;
            return items.map((item) => Recipe.fromJson(item)).toList();
          }
        }
        return [];
      },
      cacheWrite: (recipes) async {
        if (recipes.isNotEmpty) {
          await _storage.saveRecipes(recipes);
        }
      },
      cacheRead: () async {
        final cached = await _storage.getRecipes();
        if (cached == null || cached.isEmpty) return null;
        // Apply client-side search filter on cached data
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          return cached
              .where((r) =>
                  r.name.toLowerCase().contains(query) ||
                  (r.description?.toLowerCase().contains(query) ?? false))
              .toList();
        }
        return cached;
      },
    );
  }

  Future<Recipe> getRecipe(String slug) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      final demoRecipe = _getDemoRecipes().firstWhere((r) => r.slug == slug,
          orElse: () => _getDemoRecipes().first);
      return Future.value(demoRecipe);
    }

    return withOfflineFallbackSimple<Recipe>(
      apiCall: () => _api.getRecipe(slug),
      cacheWrite: (recipe) => _storage.saveRecipe(recipe),
      cacheRead: () => _storage.getRecipeBySlug(slug),
    );
  }

  Future<List<Food>> getFoods() async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoFoods();
    }

    return withOfflineFallbackSimple<List<Food>>(
      apiCall: () async {
        final response = await _api.getFoods(perPage: 1000);
        return response.items;
      },
      cacheWrite: (foods) async {
        if (foods.isNotEmpty) {
          await _storage.saveFoods(foods);
        }
      },
      cacheRead: () => _storage.getFoods(),
    );
  }

  Future<Food> createFood(Food food) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return Food(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: food.name,
        pluralName: food.pluralName,
        description: food.description,
        extras: food.extras,
        labelId: food.labelId,
        aliases: food.aliases,
        householdsWithIngredientFood: [],
        label: food.label,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
    return _api.createFood(food);
  }

  Future<void> deleteFood(String foodId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return;
    }
    return _api.deleteFood(foodId);
  }

  Future<void> deleteRecipe(String slug) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return;
    }
    return _api.deleteRecipe(slug);
  }

  /// Creates a new recipe via POST /api/recipes (name only),
  /// then fetches the full recipe, merges details, and PUTs it back.
  Future<Recipe> createRecipe(Map<String, dynamic> recipeData) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: recipeData['name'] ?? '',
        slug: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        description: recipeData['description'],
        servings: int.tryParse(recipeData['servings']?.toString() ?? '') ?? 0,
        ingredients: [],
        instructions: [],
      );
    }

    // Step 1: POST /api/recipes with just the name → returns slug
    final slug = await _api.createRecipe(recipeData['name'] ?? '');
    debugPrint('Created recipe stub with slug: $slug');

    // Step 2: GET the full recipe object so we have all default fields
    final fullRecipe = await _api.getRecipeRaw(slug);
    debugPrint('Fetched full recipe for merge, keys: ${fullRecipe.keys}');

    // Step 3: Merge our form data into the full recipe object
    // Basic fields
    if (recipeData['description'] != null && recipeData['description'].toString().isNotEmpty) {
      fullRecipe['description'] = recipeData['description'];
    }
    if (recipeData['rating'] != null) {
      final ratingValue = recipeData['rating'];
      fullRecipe['rating'] = ratingValue is int ? ratingValue : int.tryParse(ratingValue.toString()) ?? 0;
      debugPrint('Setting rating to: ${fullRecipe['rating']}');
    }

    // Yield / servings
    final servings = recipeData['servings']?.toString() ?? '';
    final recipeYield = recipeData['recipeYield']?.toString() ?? '';
    if (servings.isNotEmpty || recipeYield.isNotEmpty) {
      fullRecipe['recipeYield'] = recipeYield.isNotEmpty ? recipeYield : servings;
    }

    // Time fields
    if (recipeData['totalTime'] != null && recipeData['totalTime'].toString().isNotEmpty) {
      fullRecipe['totalTime'] = recipeData['totalTime'];
    }
    if (recipeData['prepTime'] != null && recipeData['prepTime'].toString().isNotEmpty) {
      fullRecipe['prepTime'] = recipeData['prepTime'];
    }
    if (recipeData['cookTime'] != null && recipeData['cookTime'].toString().isNotEmpty) {
      fullRecipe['performTime'] = recipeData['cookTime'];
    }

    // Ingredients: convert form data to Mealie format
    final formIngredients = recipeData['recipeIngredient'] as List? ?? [];
    if (formIngredients.isNotEmpty) {
      fullRecipe['recipeIngredient'] = formIngredients.map((ing) {
        final entry = <String, dynamic>{
          'quantity': ing['quantity'] ?? 1,
          'note': ing['note'] ?? '',
        };
        if (ing['foodId'] != null) {
          entry['food'] = {'id': ing['foodId'], 'name': ing['foodName'] ?? ''};
        }
        if (ing['unitId'] != null) {
          entry['unit'] = {'id': ing['unitId'], 'name': ing['unitName'] ?? ''};
        }
        return entry;
      }).toList();
    }

    // Instructions: convert list of step strings to Mealie format
    final instructionSteps = recipeData['recipeInstructions'] as List? ?? [];
    if (instructionSteps.isNotEmpty) {
      fullRecipe['recipeInstructions'] = instructionSteps
          .where((s) => s.toString().trim().isNotEmpty)
          .map((s) => {'text': s.toString().trim()})
          .toList();
    }

    // Categories
    final categories = recipeData['recipeCategory'] as List? ?? [];
    if (categories.isNotEmpty) {
      fullRecipe['recipeCategory'] = categories.map((c) => {'name': c}).toList();
    }

    // Tags
    final tags = recipeData['tags'] as List? ?? [];
    if (tags.isNotEmpty) {
      fullRecipe['tags'] = tags.map((t) => {'name': t}).toList();
    }

    // Tools
    final tools = recipeData['tools'] as List? ?? [];
    if (tools.isNotEmpty) {
      fullRecipe['tools'] = tools.map((t) => {'name': t}).toList();
    }

    // Notes
    final notes = recipeData['notes']?.toString() ?? '';
    if (notes.isNotEmpty) {
      fullRecipe['notes'] = [{'title': '', 'text': notes}];
    }

    debugPrint('Sending PUT with keys: ${fullRecipe.keys}');

    // Step 4: PUT /api/recipes/{slug} with the complete merged object
    final recipe = await _api.updateRecipe(slug, fullRecipe);

    // Cache the new recipe locally
    try {
      await _storage.saveRecipe(recipe);
    } catch (_) {}

    return recipe;
  }

  Future<List<ShoppingItemUnit>> getUnits() async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return [
        ShoppingItemUnit(id: 'u1', name: 'Stück'),
        ShoppingItemUnit(id: 'u2', name: 'g')
      ];
    }

    return withOfflineFallbackSimple<List<ShoppingItemUnit>>(
      apiCall: () => _api.getUnits(),
      cacheWrite: (units) async {
        if (units.isNotEmpty) {
          await _storage.saveUnits(units);
        }
      },
      cacheRead: () => _storage.getUnits(),
    );
  }

  List<Recipe> _getDemoRecipes() {
    return [
      Recipe(id: '1', name: 'Pasta Bolognese', slug: 'pasta-bolognese', totalTime: '45m', servings: 4, description: 'A classic Italian dish, perfect for the whole family.', ingredients: [RecipeIngredient(note: '500g minced meat', quantity: 500), RecipeIngredient(note: '1 can of tomatoes', quantity: 1), RecipeIngredient(note: '2 onions', quantity: 2), RecipeIngredient(note: '500g spaghetti', quantity: 500)], instructions: [RecipeInstruction(text: 'Sauté onions and minced meat.'), RecipeInstruction(text: 'Add tomatoes and simmer for 30 minutes.'), RecipeInstruction(text: 'Cook spaghetti and serve with the sauce.')]),
      Recipe(id: '2', name: 'Chicken Curry', slug: 'chicken-curry', totalTime: '30m', servings: 3, description: 'A quick and delicious curry with chicken and coconut milk.', ingredients: [RecipeIngredient(note: '400g chicken breast', quantity: 400), RecipeIngredient(note: '1 can of coconut milk', quantity: 1), RecipeIngredient(note: '2 tbsp curry paste', quantity: 2)], instructions: [RecipeInstruction(text: 'Sauté the chicken.'), RecipeInstruction(text: 'Add curry paste and coconut milk.'), RecipeInstruction(text: 'Simmer for 15 minutes and serve with rice.')]),
    ];
  }

  List<Food> _getDemoFoods() {
    return [
      Food(id: 'food-1', name: 'Apples', pluralName: 'Apples', createdAt: '', updatedAt: '', aliases: [], extras: {}, householdsWithIngredientFood: []),
      Food(id: 'food-2', name: 'Milk', pluralName: 'Milk', createdAt: '', updatedAt: '', aliases: [], extras: {}, householdsWithIngredientFood: []),
      Food(id: 'food-3', name: 'Bread', pluralName: 'Bread', createdAt: '', updatedAt: '', aliases: [], extras: {}, householdsWithIngredientFood: []),
    ];
  }
}
