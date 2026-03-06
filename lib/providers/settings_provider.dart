import 'package:flutter/material.dart';
import 'package:mealique/data/local/app_settings_storage.dart';

class SettingsProvider with ChangeNotifier {
  final AppSettingsStorage _storage;
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  bool _showCompleted = true;
  bool _showCategories = true;
  bool _isInitialized = false;

  SettingsProvider() : _storage = AppSettingsStorage();

  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get showCompleted => _showCompleted;
  bool get showCategories => _showCategories;
  bool get isInitialized => _isInitialized;

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

    // Load Shopping List preferences
    _showCompleted = await _storage.getShowCompleted();
    _showCategories = await _storage.getShowCategories();

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

  Future<void> setShowCompleted(bool value) async {
    if (_showCompleted != value) {
      _showCompleted = value;
      await _storage.saveShowCompleted(value);
      notifyListeners();
    }
  }

  Future<void> setShowCategories(bool value) async {
    if (_showCategories != value) {
      _showCategories = value;
      await _storage.saveShowCategories(value);
      notifyListeners();
    }
  }
}
