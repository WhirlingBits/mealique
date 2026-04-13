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
            final recipes =
                items.map((item) => Recipe.fromJson(item)).toList();

            // Enrich recipes with up-to-date favorite status from dedicated
            // GET /api/users/{id}/favorites endpoint.
            try {
              final favoritesMap = await _api.getUserFavorites();
              if (favoritesMap.isNotEmpty) {
                return recipes.map((r) {
                  if (favoritesMap.containsKey(r.id)) {
                    return r.copyWith(isFavorite: favoritesMap[r.id]);
                  }
                  return r;
                }).toList();
              }
            } catch (e) {
              debugPrint('getRecipes: Could not fetch favorites: $e');
            }

            return recipes;
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

  /// Returns a random recipe from the Mealie server.
  /// Uses POST /api/households/mealplans/random endpoint.
  Future<Recipe?> getRandomRecipe({
    required String date,
    required String entryType,
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      // Return a random demo recipe
      final demoRecipes = _getDemoRecipes();
      if (demoRecipes.isEmpty) return null;
      demoRecipes.shuffle();
      return demoRecipes.first;
    }

    return _api.getRandomRecipe(date: date, entryType: entryType);
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

  /// Gets an existing food by name or creates a new one if it doesn't exist.
  /// This handles the case where the food already exists (UniqueViolation error).
  Future<Food> getOrCreateFood(String foodName) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return Food(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: foodName,
        pluralName: foodName,
        description: '',
        extras: {},
        aliases: [],
        householdsWithIngredientFood: [],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }

    // First, try to find the existing food by searching
    final existingFood = await _api.searchFoodByName(foodName);
    if (existingFood != null) {
      debugPrint('getOrCreateFood: Found existing food "${existingFood.name}" with id ${existingFood.id}');
      return existingFood;
    }

    // Food doesn't exist, try to create it
    try {
      final newFood = Food(
        id: '',
        name: foodName,
        pluralName: foodName,
        description: '',
        extras: {},
        aliases: [],
        householdsWithIngredientFood: [],
        createdAt: '',
        updatedAt: '',
      );
      return await _api.createFood(newFood);
    } catch (e) {
      // If we get a UniqueViolation error, the food was created by another
      // client in the meantime - try to fetch it again
      if (e.toString().contains('UniqueViolation') ||
          e.toString().contains('duplicate key')) {
        debugPrint('getOrCreateFood: UniqueViolation caught, searching for existing food');
        final existingFood = await _api.searchFoodByName(foodName);
        if (existingFood != null) {
          return existingFood;
        }
      }
      rethrow;
    }
  }

  Future<void> deleteFood(String foodId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return;
    }
    await _api.deleteFood(foodId);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CATEGORIES
  // ───────────────────────────────────────────────────────────────────────────

  /// Fetches all recipe categories from the API.
  Future<List<RecipeCategory>> getCategories() async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoCategories();
    }
    return _api.getCategories();
  }

  /// Creates a new recipe category.
  Future<RecipeCategory> createCategory(String name) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return RecipeCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        slug: _generateSlug(name),
      );
    }
    return _api.createCategoryByName(name);
  }

  /// Gets an existing category by name or creates a new one.
  Future<RecipeCategory> getOrCreateCategory(String name) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return RecipeCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        slug: _generateSlug(name),
      );
    }

    // First, try to find existing category
    final categories = await _api.getCategories();
    final normalizedName = name.toLowerCase().trim();
    final existing = categories.cast<RecipeCategory?>().firstWhere(
      (c) => c!.name.toLowerCase().trim() == normalizedName,
      orElse: () => null,
    );
    
    if (existing != null) {
      debugPrint('getOrCreateCategory: Found existing category "${existing.name}"');
      return existing;
    }

    // Create new category
    return _api.createCategoryByName(name);
  }

  /// Deletes a recipe category by ID.
  Future<void> deleteCategory(String categoryId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return;
    }
    await _api.deleteCategory(categoryId);
  }

  List<RecipeCategory> _getDemoCategories() {
    return [
      RecipeCategory(id: '1', name: 'Hauptgericht', slug: 'hauptgericht'),
      RecipeCategory(id: '2', name: 'Vorspeise', slug: 'vorspeise'),
      RecipeCategory(id: '3', name: 'Nachspeise', slug: 'nachspeise'),
      RecipeCategory(id: '4', name: 'Frühstück', slug: 'fruehstueck'),
      RecipeCategory(id: '5', name: 'Snack', slug: 'snack'),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAGS
  // ───────────────────────────────────────────────────────────────────────────

  /// Fetches all recipe tags from the API.
  Future<List<RecipeTag>> getTags() async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoTags();
    }
    return _api.getTags();
  }

  /// Creates a new recipe tag.
  Future<RecipeTag> createTag(String name) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return RecipeTag(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        slug: _generateSlug(name),
      );
    }
    return _api.createTagByName(name);
  }

  /// Gets an existing tag by name or creates a new one.
  Future<RecipeTag> getOrCreateTag(String name) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return RecipeTag(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        slug: _generateSlug(name),
      );
    }

    // First, try to find existing tag
    final tags = await _api.getTags();
    final normalizedName = name.toLowerCase().trim();
    final existing = tags.cast<RecipeTag?>().firstWhere(
      (t) => t!.name.toLowerCase().trim() == normalizedName,
      orElse: () => null,
    );

    if (existing != null) {
      debugPrint('getOrCreateTag: Found existing tag "${existing.name}"');
      return existing;
    }

    // Create new tag
    return _api.createTagByName(name);
  }

  /// Deletes a recipe tag by ID.
  Future<void> deleteTag(String tagId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return;
    }
    await _api.deleteTag(tagId);
  }

  List<RecipeTag> _getDemoTags() {
    return [
      RecipeTag(id: '1', name: 'Vegetarisch', slug: 'vegetarisch'),
      RecipeTag(id: '2', name: 'Vegan', slug: 'vegan'),
      RecipeTag(id: '3', name: 'Schnell', slug: 'schnell'),
      RecipeTag(id: '4', name: 'Gesund', slug: 'gesund'),
      RecipeTag(id: '5', name: 'Comfort Food', slug: 'comfort-food'),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TOOLS
  // ───────────────────────────────────────────────────────────────────────────

  /// Fetches all recipe tools from the API.
  Future<List<RecipeTool>> getTools() async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoTools();
    }
    return _api.getTools();
  }

  /// Creates a new recipe tool.
  Future<RecipeTool> createTool(String name) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return RecipeTool(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        slug: _generateSlug(name),
      );
    }
    return _api.createToolByName(name);
  }

  /// Gets an existing tool by name or creates a new one.
  Future<RecipeTool> getOrCreateTool(String name) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return RecipeTool(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        slug: _generateSlug(name),
      );
    }

    // First, try to find existing tool
    final tools = await _api.getTools();
    final normalizedName = name.toLowerCase().trim();
    final existing = tools.cast<RecipeTool?>().firstWhere(
      (t) => t!.name.toLowerCase().trim() == normalizedName,
      orElse: () => null,
    );

    if (existing != null) {
      debugPrint('getOrCreateTool: Found existing tool "${existing.name}"');
      return existing;
    }

    // Create new tool
    return _api.createToolByName(name);
  }

  /// Deletes a recipe tool by ID.
  Future<void> deleteTool(String toolId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return;
    }
    await _api.deleteTool(toolId);
  }

  List<RecipeTool> _getDemoTools() {
    return [
      RecipeTool(id: '1', name: 'Mixer', slug: 'mixer'),
      RecipeTool(id: '2', name: 'Backofen', slug: 'backofen'),
      RecipeTool(id: '3', name: 'Pfanne', slug: 'pfanne'),
      RecipeTool(id: '4', name: 'Topf', slug: 'topf'),
      RecipeTool(id: '5', name: 'Schneebesen', slug: 'schneebesen'),
    ];
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
      fullRecipe['recipeCategory'] = categories.map((c) {
        // If c is already a Map (from toJson()), use it directly
        if (c is Map<String, dynamic>) {
          return c;
        }
        final name = c.toString();
        return {'name': name, 'slug': _generateSlug(name)};
      }).toList();
    }

    // Tags
    final tags = recipeData['tags'] as List? ?? [];
    if (tags.isNotEmpty) {
      fullRecipe['tags'] = tags.map((t) {
        // If t is already a Map (from toJson()), use it directly
        if (t is Map<String, dynamic>) {
          return t;
        }
        final name = t.toString();
        return {'name': name, 'slug': _generateSlug(name)};
      }).toList();
    }

    // Tools
    final tools = recipeData['tools'] as List? ?? [];
    if (tools.isNotEmpty) {
      fullRecipe['tools'] = tools.map((t) {
        // If t is already a Map (from toJson()), use it directly
        if (t is Map<String, dynamic>) {
          return t;
        }
        final name = t.toString();
        return {'name': name, 'slug': _generateSlug(name)};
      }).toList();
    }

    // Notes
    final notes = recipeData['notes']?.toString() ?? '';
    if (notes.isNotEmpty) {
      fullRecipe['notes'] = [{'title': '', 'text': notes}];
    }

    debugPrint('Sending PUT with keys: ${fullRecipe.keys}');

    // Remove rating from PUT body – Mealie ignores it; ratings are per-user.
    fullRecipe.remove('rating');

    // Step 4: PUT /api/recipes/{slug} with the complete merged object
    final recipe = await _api.updateRecipe(slug, fullRecipe);

    // Set user rating via the dedicated endpoint if provided
    if (recipeData['rating'] != null) {
      final ratingValue = recipeData['rating'];
      final ratingDouble = (ratingValue is int ? ratingValue : int.tryParse(ratingValue.toString()) ?? 0).toDouble();
      if (ratingDouble > 0) {
        try {
          await setRating(slug, ratingDouble);
        } catch (e) {
          debugPrint('Warning: Failed to set user rating on create: $e');
        }
      }
    }

    // Cache the new recipe locally
    try {
      await _storage.saveRecipe(recipe);
    } catch (_) {}

    return recipe;
  }


  /// Updates an existing recipe using PUT (full replacement).
  /// First fetches the current recipe, merges the changes, then sends the full object.
  Future<Recipe> updateExistingRecipe(String slug, Map<String, dynamic> recipeData) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return Recipe(
        id: recipeData['id'] ?? '',
        name: recipeData['name'] ?? '',
        slug: slug,
        description: recipeData['description'],
        servings: int.tryParse(recipeData['servings']?.toString() ?? '') ?? 0,
        ingredients: [],
        instructions: [],
      );
    }

    // First, GET the current recipe to get all existing fields
    debugPrint('PUT update recipe $slug - fetching current data');
    final currentRecipe = await _api.getRecipeRaw(slug);

    // Start with the original data from the server
    final putData = Map<String, dynamic>.from(currentRecipe);

    // Keep the original slug - this is required for PUT to update existing recipe
    // If we remove it, the API thinks we're creating a new recipe with the same name
    putData['slug'] = slug;

    // Update name
    if (recipeData['name'] != null && recipeData['name'].toString().isNotEmpty) {
      putData['name'] = recipeData['name'];
    }

    // Update description
    if (recipeData.containsKey('description')) {
      putData['description'] = recipeData['description'] ?? '';
    }

    // Update servings
    final servings = recipeData['servings']?.toString() ?? '';
    if (servings.isNotEmpty) {
      final servingsInt = int.tryParse(servings) ?? 0;
      if (servingsInt > 0) {
        putData['recipeServings'] = servingsInt;
      }
    }

    // Update recipe yield
    final recipeYield = recipeData['recipeYield']?.toString() ?? '';
    if (recipeYield.isNotEmpty) {
      putData['recipeYield'] = recipeYield;
    }

    // Update time fields
    if (recipeData.containsKey('totalTime')) {
      putData['totalTime'] = recipeData['totalTime'] ?? '';
    }
    if (recipeData.containsKey('prepTime')) {
      putData['prepTime'] = recipeData['prepTime'] ?? '';
    }
    if (recipeData.containsKey('cookTime')) {
      putData['performTime'] = recipeData['cookTime'] ?? '';
    }

    // Update ingredients
    if (recipeData.containsKey('recipeIngredient')) {
      final formIngredients = recipeData['recipeIngredient'] as List? ?? [];
      putData['recipeIngredient'] = formIngredients.map((ing) {
        final rawQuantity = (ing['quantity'] as num?)?.toDouble() ?? 0.0;
        final quantity = rawQuantity > 0 ? rawQuantity : 1.0;
        final foodId = ing['foodId']?.toString();
        final foodName = ing['foodName']?.toString() ?? '';
        final unitId = ing['unitId']?.toString();
        final unitName = ing['unitName']?.toString() ?? '';
        final noteText = ing['note']?.toString() ?? '';

        final entry = <String, dynamic>{
          'quantity': quantity,
        };

        if (foodId != null && foodId.isNotEmpty) {
          entry['food'] = {'id': foodId};
          if (noteText.isNotEmpty) {
            entry['note'] = noteText;
          }
        } else if (foodName.isNotEmpty) {
          final parts = <String>[];
          if (quantity > 0 && quantity != 1.0) {
            parts.add(quantity == quantity.roundToDouble()
                ? quantity.round().toString()
                : quantity.toString());
          }
          if (unitName.isNotEmpty) {
            parts.add(unitName);
          }
          parts.add(foodName);
          if (noteText.isNotEmpty) {
            parts.add('($noteText)');
          }
          entry['note'] = parts.join(' ');
        } else if (noteText.isNotEmpty) {
          entry['note'] = noteText;
        }

        if (unitId != null && unitId.isNotEmpty && foodId != null && foodId.isNotEmpty) {
          entry['unit'] = {'id': unitId};
        }

        return entry;
      }).toList();
    }

    // Update instructions
    if (recipeData.containsKey('recipeInstructions')) {
      final instructionSteps = recipeData['recipeInstructions'] as List? ?? [];
      putData['recipeInstructions'] = instructionSteps
          .where((s) => s.toString().trim().isNotEmpty)
          .map((s) => {'text': s.toString().trim()})
          .toList();
    }

    // Update categories - use existing category data from server if available
    if (recipeData.containsKey('recipeCategory')) {
      final categories = recipeData['recipeCategory'] as List? ?? [];
      final existingCategories = (currentRecipe['recipeCategory'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      // Also fetch all available categories to get full objects for new ones
      List<RecipeCategory>? allCategories;
      try {
        allCategories = await _api.getCategories();
      } catch (_) {
        allCategories = null;
      }

      putData['recipeCategory'] = categories.map((c) {
        // If c is already a Map (from toJson()), use it directly
        if (c is Map<String, dynamic>) {
          return c;
        }
        final name = c.toString();
        // Try to find the existing category in the recipe first
        final existing = existingCategories.cast<Map<String, dynamic>?>().firstWhere(
          (cat) => cat != null && cat['name']?.toString().toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
        if (existing != null) {
          // Use the existing category object (has id, groupId, name, slug)
          return existing;
        }
        // Try to find in all available categories
        if (allCategories != null) {
          final found = allCategories.cast<RecipeCategory?>().firstWhere(
            (cat) => cat != null && cat.name.toLowerCase() == name.toLowerCase(),
            orElse: () => null,
          );
          if (found != null) {
            return {'id': found.id, 'name': found.name, 'slug': found.slug};
          }
        }
        // Fallback for new categories - server will resolve these
        return {'name': name, 'slug': _generateSlug(name)};
      }).toList();
    }

    // Update tags - use existing tag data from server if available
    if (recipeData.containsKey('tags')) {
      final tags = recipeData['tags'] as List? ?? [];
      final existingTags = (currentRecipe['tags'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      putData['tags'] = tags.map((t) {
        // If t is already a Map (from toJson()), use it directly
        if (t is Map<String, dynamic>) {
          return t;
        }
        final name = t.toString();
        // Try to find the existing tag with all its fields
        final existing = existingTags.cast<Map<String, dynamic>?>().firstWhere(
          (tag) => tag != null && tag['name']?.toString().toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
        if (existing != null) {
          return existing;
        }
        return {'name': name, 'slug': _generateSlug(name)};
      }).toList();
    }

    // Update tools - use existing tool data from server if available
    if (recipeData.containsKey('tools')) {
      final tools = recipeData['tools'] as List? ?? [];
      final existingTools = (currentRecipe['tools'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      putData['tools'] = tools.map((t) {
        // If t is already a Map (from toJson()), use it directly
        if (t is Map<String, dynamic>) {
          return t;
        }
        final name = t.toString();
        // Try to find the existing tool with all its fields
        final existing = existingTools.cast<Map<String, dynamic>?>().firstWhere(
          (tool) => tool != null && tool['name']?.toString().toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
        if (existing != null) {
          return existing;
        }
        return {'name': name, 'slug': _generateSlug(name)};
      }).toList();
    }

    // Update notes
    if (recipeData.containsKey('notes')) {
      final notesText = recipeData['notes']?.toString() ?? '';
      if (notesText.isNotEmpty) {
        putData['notes'] = [{'title': '', 'text': notesText}];
      } else {
        putData['notes'] = [];
      }
    }

    debugPrint('PUT /api/recipes/$slug');
    debugPrint('PUT recipeCategory: ${putData['recipeCategory']}');
    final recipe = await _api.updateRecipe(slug, putData);

    // Mealie stores ratings per-user via a separate endpoint
    if (recipeData.containsKey('rating')) {
      final ratingValue = recipeData['rating'];
      final ratingDouble = (ratingValue is int ? ratingValue : int.tryParse(ratingValue.toString()) ?? 0).toDouble();
      debugPrint('Setting user rating to $ratingDouble for recipe $slug (id=${recipe.id})');
      try {
        await setRating(slug, ratingDouble);
      } catch (e) {
        debugPrint('Warning: Failed to set user rating: $e');
      }
    }

    try {
      await _storage.saveRecipe(recipe);
    } catch (_) {}

    return recipe;
  }

  /// Sets the user rating for a recipe via the dedicated Mealie ratings
  /// endpoint (POST /api/users/{userId}/ratings/{slug}).
  /// This does NOT do a full recipe GET+PUT cycle.
  Future<void> setRating(String slug, double rating) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;

    // Ensure we have a userId cached; fetch it if missing.
    var userId = await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('setRating: userId not cached, fetching from /api/users/self');
      try {
        final response = await _api.fetchAndCacheUserId();
        userId = response;
      } catch (e) {
        debugPrint('setRating: Failed to fetch userId: $e');
        return;
      }
    }

    try {
      await _api.setRating(slug, rating);
    } catch (e) {
      debugPrint('setRating: Failed to set rating: $e');
      rethrow;
    }
  }

  /// Returns the current favorite status for a recipe by slug.
  Future<bool> getFavoriteStatus(String slug) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return false;

    var userId = await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      try {
        userId = await _api.fetchAndCacheUserId();
      } catch (_) {
        return false;
      }
    }

    return _api.getFavoriteStatus(slug);
  }

  /// Returns the current favorite status for a recipe by ID (UUID).
  /// More efficient than getFavoriteStatus when you already have the recipeId.
  Future<bool> getFavoriteStatusById(String recipeId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return false;

    var userId = await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      try {
        userId = await _api.fetchAndCacheUserId();
      } catch (_) {
        return false;
      }
    }

    return _api.getFavoriteStatusById(recipeId);
  }

  /// Sets or clears the favorite flag for a recipe.
  Future<void> setFavorite(String slug, {required bool isFavorite}) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;

    var userId = await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      try {
        userId = await _api.fetchAndCacheUserId();
      } catch (e) {
        debugPrint('setFavorite: Failed to fetch userId: $e');
        return;
      }
    }

    await _api.setFavorite(slug, isFavorite: isFavorite);
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

  /// Generates a URL-friendly slug from a name.
  /// Converts to lowercase, replaces spaces and special characters with hyphens.
  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[äÄ]'), 'ae')
        .replaceAll(RegExp(r'[öÖ]'), 'oe')
        .replaceAll(RegExp(r'[üÜ]'), 'ue')
        .replaceAll(RegExp(r'ß'), 'ss')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
