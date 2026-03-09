import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mealique/models/food_model.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/models/shopping_item_model.dart';

import 'connection/connection.dart';

part 'recipe_storage.g.dart';

// --- Table Definitions ---

/// Stores recipes as raw JSON blobs for simplicity (avoids complex table schemas
/// for nested ingredients/instructions).
@DataClassName('CachedRecipeEntry')
class CachedRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text()();
  TextColumn get jsonData => text()();
  TextColumn get updatedAt => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores foods as raw JSON blobs.
@DataClassName('CachedFoodEntry')
class CachedFoods extends Table {
  TextColumn get id => text()();
  TextColumn get jsonData => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores units as raw JSON blobs.
@DataClassName('CachedUnitEntry')
class CachedUnits extends Table {
  TextColumn get id => text()();
  TextColumn get jsonData => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- Database ---

@DriftDatabase(tables: [CachedRecipes, CachedFoods, CachedUnits])
class RecipeDatabase extends _$RecipeDatabase {
  RecipeDatabase._() : super(openConnection(name: 'recipe_cache'));

  static final RecipeDatabase _instance = RecipeDatabase._();
  factory RecipeDatabase() => _instance;

  @override
  int get schemaVersion => 1;
}

// --- Storage Service ---

class RecipeStorage {
  final RecipeDatabase _db = RecipeDatabase();

  // ---- Recipes ----

  Future<void> saveRecipes(List<Recipe> recipes) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.cachedRecipes,
        recipes.map((r) => CachedRecipesCompanion(
          id: Value(r.id),
          slug: Value(r.slug),
          jsonData: Value(json.encode(_recipeToStorageJson(r))),
          updatedAt: Value(DateTime.now().toIso8601String()),
        )).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> saveRecipe(Recipe recipe) async {
    await _db.into(_db.cachedRecipes).insertOnConflictUpdate(
      CachedRecipesCompanion(
        id: Value(recipe.id),
        slug: Value(recipe.slug),
        jsonData: Value(json.encode(_recipeToStorageJson(recipe))),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<List<Recipe>?> getRecipes() async {
    final entries = await _db.select(_db.cachedRecipes).get();
    if (entries.isEmpty) return null;
    return entries
        .map((e) => Recipe.fromJson(json.decode(e.jsonData) as Map<String, dynamic>))
        .toList();
  }

  Future<Recipe?> getRecipeBySlug(String slug) async {
    final query = _db.select(_db.cachedRecipes)
      ..where((t) => t.slug.equals(slug));
    final entries = await query.get();
    if (entries.isEmpty) return null;
    return Recipe.fromJson(json.decode(entries.first.jsonData) as Map<String, dynamic>);
  }

  Future<void> clearRecipes() async {
    await _db.delete(_db.cachedRecipes).go();
  }

  // ---- Foods ----

  Future<void> saveFoods(List<Food> foods) async {
    await _db.delete(_db.cachedFoods).go();
    await _db.batch((batch) {
      batch.insertAll(
        _db.cachedFoods,
        foods.map((f) => CachedFoodsCompanion(
          id: Value(f.id),
          jsonData: Value(json.encode(_foodToJson(f))),
        )).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<Food>?> getFoods() async {
    final entries = await _db.select(_db.cachedFoods).get();
    if (entries.isEmpty) return null;
    return entries
        .map((e) => Food.fromJson(json.decode(e.jsonData) as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearFoods() async {
    await _db.delete(_db.cachedFoods).go();
  }

  // ---- Units ----

  Future<void> saveUnits(List<ShoppingItemUnit> units) async {
    await _db.delete(_db.cachedUnits).go();
    await _db.batch((batch) {
      batch.insertAll(
        _db.cachedUnits,
        units.map((u) => CachedUnitsCompanion(
          id: Value(u.id),
          jsonData: Value(json.encode({'id': u.id, 'name': u.name})),
        )).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<ShoppingItemUnit>?> getUnits() async {
    final entries = await _db.select(_db.cachedUnits).get();
    if (entries.isEmpty) return null;
    return entries
        .map((e) => ShoppingItemUnit.fromJson(json.decode(e.jsonData) as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearUnits() async {
    await _db.delete(_db.cachedUnits).go();
  }

  // ---- Clear All ----

  Future<void> clearAll() async {
    await Future.wait([
      clearRecipes(),
      clearFoods(),
      clearUnits(),
    ]);
  }

  // ---- Private Helpers ----

  Map<String, dynamic> _recipeToStorageJson(Recipe recipe) {
    return {
      'id': recipe.id,
      'name': recipe.name,
      'slug': recipe.slug,
      'image': recipe.image,
      'description': recipe.description,
      'totalTime': recipe.totalTime,
      'prepTime': recipe.prepTime,
      'performTime': recipe.performTime,
      'recipeYield': recipe.servings,
      'recipeIngredient': recipe.ingredients.map((i) => {
        'note': i.note,
        'quantity': i.quantity,
        if (i.unit != null) 'unit': {'name': i.unit},
        if (i.food != null) 'food': {'name': i.food},
      }).toList(),
      'recipeInstructions': recipe.instructions.map((i) => {
        'text': i.text,
      }).toList(),
    };
  }

  Map<String, dynamic> _foodToJson(Food food) {
    return {
      'id': food.id,
      'name': food.name,
      'pluralName': food.pluralName,
      'description': food.description,
      'extras': food.extras,
      'labelId': food.labelId,
      'aliases': food.aliases,
      'householdsWithIngredientFood': food.householdsWithIngredientFood,
      'label': food.label != null
          ? {
              'id': food.label!.id,
              'name': food.label!.name,
              'color': food.label!.color,
              'groupId': food.label!.groupId,
            }
          : null,
      'createdAt': food.createdAt,
      'updatedAt': food.updatedAt,
    };
  }
}

