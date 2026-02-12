import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mealique/models/cookbook_model.dart';
import 'package:mealique/models/mealplan_model.dart';
import 'package:mealique/models/mealplan_rule_model.dart';
import 'package:mealique/models/shopping_item_model.dart';
import 'package:mealique/models/shopping_list_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'household_storage.g.dart';

// --- Type Converters ---

class HouseholdConverter extends TypeConverter<Household, String> {
  const HouseholdConverter();
  @override
  Household fromSql(String fromDb) {
    return Household.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(Household value) {
    return json.encode({'id': value.id, 'name': value.name});
  }
}

class QueryFilterConverter extends TypeConverter<QueryFilter, String> {
  const QueryFilterConverter();
  @override
  QueryFilter fromSql(String fromDb) {
    return QueryFilter.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(QueryFilter value) {
    return json.encode({'parts': value.parts});
  }
}

class ExtrasMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const ExtrasMapConverter();
  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    return json.decode(fromDb) as Map<String, dynamic>;
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return json.encode(value);
  }
}

class RecipeReferencesConverter extends TypeConverter<List<ShoppingListRecipeReference>, String> {
  const RecipeReferencesConverter();
  @override
  List<ShoppingListRecipeReference> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return (json.decode(fromDb) as List)
        .map((i) => ShoppingListRecipeReference.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<ShoppingListRecipeReference> value) {
    return json.encode(value.map((i) => i.toDriftJson()).toList());
  }
}

class LabelSettingsConverter extends TypeConverter<List<ShoppingListLabelSetting>, String> {
  const LabelSettingsConverter();
  @override
  List<ShoppingListLabelSetting> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return (json.decode(fromDb) as List)
        .map((i) => ShoppingListLabelSetting.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<ShoppingListLabelSetting> value) {
    return json.encode(value.map((i) => i.toDriftJson()).toList());
  }
}

class ListItemsConverter extends TypeConverter<List<ShoppingItem>, String> {
  const ListItemsConverter();
  @override
  List<ShoppingItem> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return (json.decode(fromDb) as List)
        .map((i) => ShoppingItem.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<ShoppingItem> value) {
    return json.encode(value.map((item) => item.toJson()).toList());
  }
}

class MealplanRuleQueryFilterConverter extends TypeConverter<MealplanRuleQueryFilter, String> {
  const MealplanRuleQueryFilterConverter();
  @override
  MealplanRuleQueryFilter fromSql(String fromDb) {
    return MealplanRuleQueryFilter.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(MealplanRuleQueryFilter value) {
    return json.encode({'parts': value.parts});
  }
}

class MealplanRecipeConverter extends TypeConverter<MealplanRecipe?, String?> {
  const MealplanRecipeConverter();
  @override
  MealplanRecipe? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    return MealplanRecipe.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String? toSql(MealplanRecipe? value) {
    if (value == null) return null;
    return json.encode({'id': value.id, 'name': value.name, 'slug': value.slug});
  }
}

// --- Table Definitions ---

@DataClassName('CookbookEntry')
class Cookbooks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get slug => text()();
  IntColumn get position => integer()();
  BoolColumn get public => boolean()();
  TextColumn get queryFilterString => text()();
  TextColumn get groupId => text()();
  TextColumn get householdId => text()();
  TextColumn get queryFilter => text().map(const QueryFilterConverter())();
  TextColumn get household => text().map(const HouseholdConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ShoppingListEntry')
class ShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get extras => text().map(const ExtrasMapConverter())();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get groupId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get householdId => text().nullable()();
  TextColumn get recipeReferences => text().map(const RecipeReferencesConverter())();
  TextColumn get labelSettings => text().map(const LabelSettingsConverter())();
  TextColumn get listItems => text().map(const ListItemsConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MealplanRuleEntry')
class MealplanRules extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()();
  TextColumn get entryType => text()();
  TextColumn get queryFilterString => text()();
  TextColumn get groupId => text()();
  TextColumn get householdId => text()();
  TextColumn get queryFilter => text().map(const MealplanRuleQueryFilterConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

// Fix: Umbenannt in MealplanDbEntry, um Konflikte mit dem Domain-Model MealplanEntry zu vermeiden
@DataClassName('MealplanDbEntry')
class Mealplans extends Table {
  IntColumn get id => integer()();
  TextColumn get date => text()();
  TextColumn get entryType => text()();
  TextColumn get title => text().nullable()();
  TextColumn get contentText => text().named('text').nullable()();
  TextColumn get recipeId => text().nullable()();
  TextColumn get recipe => text().nullable().map(const MealplanRecipeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

// --- Database Class ---

@DriftDatabase(tables: [Cookbooks, ShoppingLists, MealplanRules, Mealplans])
class HouseholdDatabase extends _$HouseholdDatabase {
  HouseholdDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mealique.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// --- Mappers ---

extension on Cookbook {
  CookbooksCompanion toDriftCompanion() {
    return CookbooksCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      slug: Value(slug),
      position: Value(position),
      public: Value(public),
      queryFilterString: Value(queryFilterString),
      groupId: Value(groupId),
      householdId: Value(householdId),
      queryFilter: Value(queryFilter),
      household: Value(household),
    );
  }
}

extension on CookbookEntry {
  Cookbook toDomainModel() {
    return Cookbook(
      id: id,
      name: name,
      description: description,
      slug: slug,
      position: position,
      public: public,
      queryFilterString: queryFilterString,
      groupId: groupId,
      householdId: householdId,
      queryFilter: queryFilter,
      household: household,
    );
  }
}

extension on ShoppingListRecipeReference {
  Map<String, dynamic> toDriftJson() => {
    'id': id,
    'shoppingListId': shoppingListId,
    'recipeId': recipeId,
    'recipeQuantity': recipeQuantity,
    'recipe': {
      'id': recipe.id,
      'name': recipe.name,
      'slug': recipe.slug,
      'recipeServings': recipe.recipeServings,
    },
  };
}

extension on ShoppingListLabelSetting {
  Map<String, dynamic> toDriftJson() => {
    'shoppingListId': shoppingListId,
    'labelId': labelId,
    'position': position,
    'id': id,
    'label': {
      'name': label.name,
      'color': label.color,
      'groupId': label.groupId,
      'id': label.id,
    },
  };
}

extension on ShoppingList {
  ShoppingListsCompanion toDriftCompanion() {
    return ShoppingListsCompanion(
      id: Value(id),
      name: Value(name),
      extras: Value(extras),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      groupId: Value(groupId),
      userId: Value(userId),
      householdId: Value(householdId),
      recipeReferences: Value(recipeReferences),
      labelSettings: Value(labelSettings),
      listItems: Value(listItems),
    );
  }
}

extension on ShoppingListEntry {
  ShoppingList toDomainModel() {
    return ShoppingList(
      id: id,
      name: name,
      extras: extras,
      createdAt: createdAt,
      updatedAt: updatedAt,
      groupId: groupId,
      userId: userId,
      householdId: householdId,
      recipeReferences: recipeReferences,
      labelSettings: labelSettings,
      listItems: listItems,
    );
  }
}

extension on MealplanRule {
  MealplanRulesCompanion toDriftCompanion() {
    return MealplanRulesCompanion(
      id: Value(id),
      day: Value(day),
      entryType: Value(entryType),
      queryFilterString: Value(queryFilterString),
      groupId: Value(groupId),
      householdId: Value(householdId),
      queryFilter: Value(queryFilter),
    );
  }
}

extension on MealplanRuleEntry {
  MealplanRule toDomainModel() {
    return MealplanRule(
      id: id,
      day: day,
      entryType: entryType,
      queryFilterString: queryFilterString,
      groupId: groupId,
      householdId: householdId,
      queryFilter: queryFilter,
    );
  }
}

extension on MealplanEntry {
  MealplansCompanion toDriftCompanion() {
    return MealplansCompanion(
      id: Value(id),
      date: Value(date),
      entryType: Value(entryType.name),
      title: Value(title),
      contentText: Value(text),
      recipeId: Value(recipeId),
      recipe: Value(recipe),
    );
  }
}

extension on MealplanDbEntry {
  MealplanEntry toDomainModel() {
    return MealplanEntry(
      id: id,
      date: date,
      entryType: PlanEntryType.fromString(entryType),
      title: title,
      text: contentText,
      recipeId: recipeId,
      recipe: recipe,
    );
  }
}

// --- HouseholdStorage using Drift ---
class HouseholdStorage {
  final HouseholdDatabase _db = HouseholdDatabase();

  Future<void> saveCookbooks(List<Cookbook> cookbooks) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.cookbooks,
        cookbooks.map((e) => e.toDriftCompanion()).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<Cookbook>?> getCookbooks() async {
    final entries = await _db.select(_db.cookbooks).get();
    return entries.isNotEmpty
        ? entries.map((entry) => entry.toDomainModel()).toList()
        : null;
  }

  Future<void> clearCookbooks() async {
    await _db.delete(_db.cookbooks).go();
  }

  Future<void> saveShoppingLists(List<ShoppingList> shoppingLists) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.shoppingLists,
        shoppingLists.map((e) => e.toDriftCompanion()).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<ShoppingList>?> getShoppingLists() async {
    // FIX: _dio.select durch _db.select ersetzt
    final entries = await _db.select(_db.shoppingLists).get();
    return entries.isNotEmpty
        ? entries.map((entry) => entry.toDomainModel()).toList()
        : null;
  }

  Future<void> clearShoppingLists() async {
    await _db.delete(_db.shoppingLists).go();
  }

  Future<void> saveMealplanRules(List<MealplanRule> rules) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.mealplanRules,
        rules.map((e) => e.toDriftCompanion()).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<MealplanRule>?> getMealplanRules() async {
    final entries = await _db.select(_db.mealplanRules).get();
    return entries.isNotEmpty
        ? entries.map((entry) => entry.toDomainModel()).toList()
        : null;
  }

  Future<void> clearMealplanRules() async {
    await _db.delete(_db.mealplanRules).go();
  }

  Future<void> saveMealplans(List<MealplanEntry> mealplans) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.mealplans,
        mealplans.map((e) => e.toDriftCompanion()).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<MealplanEntry>?> getMealplans() async {
    final entries = await _db.select(_db.mealplans).get();
    return entries.isNotEmpty
        ? entries.map((entry) => entry.toDomainModel()).toList()
        : null;
  }

  Future<void> clearMealplans() async {
    await _db.delete(_db.mealplans).go();
  }

  /// Clears all data from the local household database.
  Future<void> clearAll() async {
    await Future.wait([
      clearCookbooks(),
      clearShoppingLists(),
      clearMealplanRules(),
      clearMealplans(),
    ]);
  }
}
