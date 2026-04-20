import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lokaler Cache für Food-Label-Zuordnungen.
/// Wenn ein Lebensmittel mit einem Label verknüpft wird, wird diese
/// Zuordnung hier gespeichert. Beim Neuerstellen eines Shopping-Items
/// wird automatisch das gespeicherte Label zugewiesen.
class FoodLabelCache {
  static const String _cacheKey = 'food_label_mappings';

  /// Singleton-Instanz
  static final FoodLabelCache _instance = FoodLabelCache._internal();
  factory FoodLabelCache() => _instance;
  FoodLabelCache._internal();

  /// In-Memory Cache für schnelleren Zugriff
  Map<String, String>? _cache;

  /// Lädt alle Food-Label-Mappings aus dem Cache.
  Future<Map<String, String>> _loadCache() async {
    if (_cache != null) return _cache!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        _cache = decoded.map((k, v) => MapEntry(k, v.toString()));
        debugPrint('FoodLabelCache: Loaded ${_cache!.length} mappings');
      } else {
        _cache = {};
      }
    } catch (e) {
      debugPrint('FoodLabelCache: Error loading cache: $e');
      _cache = {};
    }

    return _cache!;
  }

  /// Speichert den Cache persistent.
  Future<void> _saveCache() async {
    if (_cache == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_cache);
      await prefs.setString(_cacheKey, jsonStr);
      debugPrint('FoodLabelCache: Saved ${_cache!.length} mappings');
    } catch (e) {
      debugPrint('FoodLabelCache: Error saving cache: $e');
    }
  }

  /// Normalisiert einen Food-Namen für konsistente Lookups.
  String _normalizeKey(String foodName) {
    return foodName.toLowerCase().trim();
  }

  /// Speichert eine Food-Label-Zuordnung.
  /// [foodName] ist der Name des Lebensmittels.
  /// [labelId] ist die ID des Labels (null zum Entfernen).
  Future<void> setLabel(String foodName, String? labelId) async {
    final cache = await _loadCache();
    final key = _normalizeKey(foodName);

    if (labelId != null && labelId.isNotEmpty) {
      cache[key] = labelId;
      debugPrint('FoodLabelCache: Set "$foodName" → labelId=$labelId');
    } else {
      cache.remove(key);
      debugPrint('FoodLabelCache: Removed label for "$foodName"');
    }

    await _saveCache();
  }

  /// Holt die gespeicherte Label-ID für ein Lebensmittel.
  /// Gibt null zurück, wenn keine Zuordnung existiert.
  Future<String?> getLabel(String foodName) async {
    final cache = await _loadCache();
    final key = _normalizeKey(foodName);
    final labelId = cache[key];

    if (labelId != null) {
      debugPrint('FoodLabelCache: Found cached label for "$foodName": $labelId');
    }

    return labelId;
  }

  /// Speichert mehrere Food-Label-Zuordnungen auf einmal.
  Future<void> setLabels(Map<String, String> mappings) async {
    final cache = await _loadCache();

    for (final entry in mappings.entries) {
      final key = _normalizeKey(entry.key);
      cache[key] = entry.value;
    }

    await _saveCache();
    debugPrint('FoodLabelCache: Set ${mappings.length} labels');
  }

  /// Löscht alle gespeicherten Zuordnungen.
  Future<void> clear() async {
    _cache = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    debugPrint('FoodLabelCache: Cleared all mappings');
  }

  /// Gibt alle gespeicherten Zuordnungen zurück (für Debugging).
  Future<Map<String, String>> getAll() async {
    return Map.from(await _loadCache());
  }
}

