import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettingsStorage {
  final _storage = const FlutterSecureStorage();
  static const _keyLocale = 'app_locale';
  static const _keyThemeMode = 'theme_mode';

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
}
