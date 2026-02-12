import 'package:flutter/material.dart';
import 'package:mealique/data/local/app_settings_storage.dart';

class SettingsProvider with ChangeNotifier {
  final AppSettingsStorage _storage;
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  SettingsProvider() : _storage = AppSettingsStorage() {
    _loadSettings();
  }

  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void _loadSettings() async {
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
}
