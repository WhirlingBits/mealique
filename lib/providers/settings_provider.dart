import 'package:flutter/material.dart';
import 'package:mealique/data/local/app_settings_storage.dart';

class SettingsProvider with ChangeNotifier {
  final AppSettingsStorage _storage;
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;
  String? _recipeSortField;
  String _recipeSortDirection = 'asc';
  String? _shoppingListSortField;
  String _shoppingListSortDirection = 'asc';

  // Per-list settings (cached in memory)
  final Map<String, bool> _showCompletedPerList = {};
  final Map<String, bool> _showCategoriesPerList = {};
  final Map<String, String?> _shoppingItemSortFieldPerList = {};
  final Map<String, String> _shoppingItemSortDirectionPerList = {};

  SettingsProvider() : _storage = AppSettingsStorage();

  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;
  String? get recipeSortField => _recipeSortField;
  String get recipeSortDirection => _recipeSortDirection;
  String? get shoppingListSortField => _shoppingListSortField;
  String get shoppingListSortDirection => _shoppingListSortDirection;

  // Per-list getters
  bool showCompletedForList(String listId) =>
      _showCompletedPerList[listId] ?? true;

  bool showCategoriesForList(String listId) =>
      _showCategoriesPerList[listId] ?? true;

  String? shoppingItemSortFieldForList(String listId) =>
      _shoppingItemSortFieldPerList[listId];

  String shoppingItemSortDirectionForList(String listId) =>
      _shoppingItemSortDirectionPerList[listId] ?? 'asc';

  /// Call once at app startup before building the widget tree.
  Future<void> init() async {
    if (_isInitialized) return;

    // Load Locale
    final localeString = await _storage.getLocale();
    if (localeString != null) {
      _locale = Locale(localeString);
    }

    // Load Theme
    final savedThemeMode = await _storage.getThemeMode();
    if (savedThemeMode != null) {
      _themeMode = savedThemeMode;
    }

    // Load Sort preferences
    _recipeSortField = await _storage.getRecipeSortField();
    _recipeSortDirection = await _storage.getRecipeSortDirection();
    _shoppingListSortField = await _storage.getShoppingListSortField();
    _shoppingListSortDirection = await _storage.getShoppingListSortDirection();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      await _storage.saveLocale(newLocale.languageCode);
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      await _storage.saveThemeMode(newThemeMode);
      notifyListeners();
    }
  }

  Future<void> setShowCompleted(String listId, bool value) async {
    if (_showCompletedPerList[listId] != value) {
      _showCompletedPerList[listId] = value;
      await _storage.saveShowCompleted(listId, value);
      notifyListeners();
    }
  }

  Future<void> setShowCategories(String listId, bool value) async {
    if (_showCategoriesPerList[listId] != value) {
      _showCategoriesPerList[listId] = value;
      await _storage.saveShowCategories(listId, value);
      notifyListeners();
    }
  }

  Future<void> setRecipeSort(String? field, String direction) async {
    _recipeSortField = field;
    _recipeSortDirection = direction;
    await _storage.saveRecipeSortField(field);
    await _storage.saveRecipeSortDirection(direction);
    notifyListeners();
  }

  Future<void> setShoppingListSort(String? field, String direction) async {
    _shoppingListSortField = field;
    _shoppingListSortDirection = direction;
    await _storage.saveShoppingListSortField(field);
    await _storage.saveShoppingListSortDirection(direction);
    notifyListeners();
  }

  Future<void> setShoppingItemSort(String listId, String? field, String direction) async {
    _shoppingItemSortFieldPerList[listId] = field;
    _shoppingItemSortDirectionPerList[listId] = direction;
    await _storage.saveShoppingItemSortField(listId, field);
    await _storage.saveShoppingItemSortDirection(listId, direction);
    notifyListeners();
  }

  /// Load per-list settings from storage (call when opening a list detail screen)
  Future<void> loadListSettings(String listId) async {
    _showCompletedPerList[listId] = await _storage.getShowCompleted(listId);
    _showCategoriesPerList[listId] = await _storage.getShowCategories(listId);
    _shoppingItemSortFieldPerList[listId] = await _storage.getShoppingItemSortField(listId);
    _shoppingItemSortDirectionPerList[listId] = await _storage.getShoppingItemSortDirection(listId);
    notifyListeners();
  }
}
