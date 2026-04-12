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

  // Notification settings keys
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyBreakfastReminderEnabled = 'breakfast_reminder_enabled';
  static const _keyLunchReminderEnabled = 'lunch_reminder_enabled';
  static const _keyDinnerReminderEnabled = 'dinner_reminder_enabled';
  static const _keyBreakfastTime = 'breakfast_time';
  static const _keyLunchTime = 'lunch_time';
  static const _keyDinnerTime = 'dinner_time';

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

  // --- Notification Settings --- //
  Future<void> saveNotificationsEnabled(bool value) =>
      _storage.write(key: _keyNotificationsEnabled, value: value.toString());

  Future<bool> getNotificationsEnabled() async {
    final val = await _storage.read(key: _keyNotificationsEnabled);
    return val == 'true';
  }

  Future<void> saveBreakfastReminderEnabled(bool value) =>
      _storage.write(key: _keyBreakfastReminderEnabled, value: value.toString());

  Future<bool> getBreakfastReminderEnabled() async {
    final val = await _storage.read(key: _keyBreakfastReminderEnabled);
    return val == 'true';
  }

  Future<void> saveLunchReminderEnabled(bool value) =>
      _storage.write(key: _keyLunchReminderEnabled, value: value.toString());

  Future<bool> getLunchReminderEnabled() async {
    final val = await _storage.read(key: _keyLunchReminderEnabled);
    return val == 'true';
  }

  Future<void> saveDinnerReminderEnabled(bool value) =>
      _storage.write(key: _keyDinnerReminderEnabled, value: value.toString());

  Future<bool> getDinnerReminderEnabled() async {
    final val = await _storage.read(key: _keyDinnerReminderEnabled);
    return val == 'true';
  }

  Future<void> saveBreakfastTime(TimeOfDay time) =>
      _storage.write(key: _keyBreakfastTime, value: '${time.hour}:${time.minute}');

  Future<TimeOfDay?> getBreakfastTime() async {
    final val = await _storage.read(key: _keyBreakfastTime);
    return _parseTimeOfDay(val);
  }

  Future<void> saveLunchTime(TimeOfDay time) =>
      _storage.write(key: _keyLunchTime, value: '${time.hour}:${time.minute}');

  Future<TimeOfDay?> getLunchTime() async {
    final val = await _storage.read(key: _keyLunchTime);
    return _parseTimeOfDay(val);
  }

  Future<void> saveDinnerTime(TimeOfDay time) =>
      _storage.write(key: _keyDinnerTime, value: '${time.hour}:${time.minute}');

  Future<TimeOfDay?> getDinnerTime() async {
    final val = await _storage.read(key: _keyDinnerTime);
    return _parseTimeOfDay(val);
  }

  TimeOfDay? _parseTimeOfDay(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
