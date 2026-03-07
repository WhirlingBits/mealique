import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettingsStorage {
  final _storage = const FlutterSecureStorage();
  static const _keyLocale = 'app_locale';
  static const _keyThemeMode = 'theme_mode';
  static const _keyRecipeSortField = 'recipe_sort_field';
  static const _keyRecipeSortDirection = 'recipe_sort_direction';
  static const _keyShoppingListSortField = 'shopping_list_sort_field';
  static const _keyShoppingListSortDirection = 'shopping_list_sort_direction';

  // Per-list settings key prefixes
  static const _keyShowCompletedPrefix = 'shopping_show_completed_';
  static const _keyShowCategoriesPrefix = 'shopping_show_categories_';
  static const _keyShoppingItemSortFieldPrefix = 'shopping_item_sort_field_';
  static const _keyShoppingItemSortDirectionPrefix = 'shopping_item_sort_direction_';

  // --- Locale --- //
  Future<void> saveLocale(String locale) => _storage.write(key: _keyLocale, value: locale);
  Future<String?> getLocale() => _storage.read(key: _keyLocale);

  // --- Theme Mode --- //
  Future<void> saveThemeMode(ThemeMode mode) => _storage.write(key: _keyThemeMode, value: mode.name);

  Future<ThemeMode?> getThemeMode() async {
    final themeName = await _storage.read(key: _keyThemeMode);
    if (themeName == null) return null;
    try {
      return ThemeMode.values.byName(themeName);
    } catch (_) {
      return null;
    }
  }

  // --- Shopping List Detail: Show Completed Items (per list) --- //
  Future<void> saveShowCompleted(String listId, bool value) =>
      _storage.write(key: '$_keyShowCompletedPrefix$listId', value: value.toString());

  Future<bool> getShowCompleted(String listId) async {
    final val = await _storage.read(key: '$_keyShowCompletedPrefix$listId');
    return val != 'false'; // default true
  }

  // --- Shopping List Detail: Show Categories (per list) --- //
  Future<void> saveShowCategories(String listId, bool value) =>
      _storage.write(key: '$_keyShowCategoriesPrefix$listId', value: value.toString());

  Future<bool> getShowCategories(String listId) async {
    final val = await _storage.read(key: '$_keyShowCategoriesPrefix$listId');
    return val != 'false'; // default true
  }

  // --- Recipe Sort --- //
  Future<void> saveRecipeSortField(String? field) =>
      field != null
          ? _storage.write(key: _keyRecipeSortField, value: field)
          : _storage.delete(key: _keyRecipeSortField);

  Future<String?> getRecipeSortField() => _storage.read(key: _keyRecipeSortField);

  Future<void> saveRecipeSortDirection(String direction) =>
      _storage.write(key: _keyRecipeSortDirection, value: direction);

  Future<String> getRecipeSortDirection() async {
    final val = await _storage.read(key: _keyRecipeSortDirection);
    return val ?? 'asc';
  }

  // --- Shopping List Sort --- //
  Future<void> saveShoppingListSortField(String? field) =>
      field != null
          ? _storage.write(key: _keyShoppingListSortField, value: field)
          : _storage.delete(key: _keyShoppingListSortField);

  Future<String?> getShoppingListSortField() => _storage.read(key: _keyShoppingListSortField);

  Future<void> saveShoppingListSortDirection(String direction) =>
      _storage.write(key: _keyShoppingListSortDirection, value: direction);

  Future<String> getShoppingListSortDirection() async {
    final val = await _storage.read(key: _keyShoppingListSortDirection);
    return val ?? 'asc';
  }

  // --- Shopping Item Sort (items within a specific list) --- //
  Future<void> saveShoppingItemSortField(String listId, String? field) =>
      field != null
          ? _storage.write(key: '$_keyShoppingItemSortFieldPrefix$listId', value: field)
          : _storage.delete(key: '$_keyShoppingItemSortFieldPrefix$listId');

  Future<String?> getShoppingItemSortField(String listId) =>
      _storage.read(key: '$_keyShoppingItemSortFieldPrefix$listId');

  Future<void> saveShoppingItemSortDirection(String listId, String direction) =>
      _storage.write(key: '$_keyShoppingItemSortDirectionPrefix$listId', value: direction);

  Future<String> getShoppingItemSortDirection(String listId) async {
    final val = await _storage.read(key: '$_keyShoppingItemSortDirectionPrefix$listId');
    return val ?? 'asc';
  }
}
