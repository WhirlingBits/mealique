import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mealique/data/remote/dio_client.dart';
import 'package:mealique/models/shopping_item_model.dart';
import '../local/token_storage.dart';

/// API-Client für Shopping-Labels (Kategorien wie "Obst & Gemüse", "Milch & Käse", etc.)
class LabelsApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  static List<ShoppingItemLabel>? _labelsCache;
  static DateTime? _labelsCacheTimestamp;
  static Future<List<ShoppingItemLabel>>? _inFlightGetLabels;
  static const Duration _labelsCacheTtl = Duration(minutes: 5);

  LabelsApi()
      : _tokenStorage = TokenStorage(),
        _dio = DioClient.createDio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.baseUrl.isEmpty) {
          final serverUrl = await _tokenStorage.getServerUrl();
          if (serverUrl != null && serverUrl.isNotEmpty) {
            options.baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
          }
        }

        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
    ));
  }

  /// Leert den RAM-Cache (z. B. beim Logout).
  static void clearRamCache() {
    _labelsCache = null;
    _labelsCacheTimestamp = null;
    _inFlightGetLabels = null;
  }

  /// Gibt gecachte Labels zurück ohne API-Aufruf. Gibt null zurück, wenn kein RAM-Cache vorhanden.
  List<ShoppingItemLabel>? getLabelsLocalOnly() => _labelsCache;

  /// GET /api/groups/labels - Ruft alle Labels ab
  Future<List<ShoppingItemLabel>> getLabels({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final hasFreshCache =
        !forceRefresh &&
        _labelsCache != null &&
        _labelsCacheTimestamp != null &&
        now.difference(_labelsCacheTimestamp!) < _labelsCacheTtl;

    if (hasFreshCache) {
      return _labelsCache!;
    }

    if (_inFlightGetLabels != null) {
      return _inFlightGetLabels!;
    }

    final request = _fetchLabels();
    _inFlightGetLabels = request;

    try {
      return await request;
    } finally {
      _inFlightGetLabels = null;
    }
  }

  Future<List<ShoppingItemLabel>> _fetchLabels() async {
    try {
      final response = await _dio.get('api/groups/labels');
      List<ShoppingItemLabel> labels = const [];

      if (response.data is List) {
        labels = (response.data as List)
            .map((e) => ShoppingItemLabel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map && response.data['items'] is List) {
        labels = (response.data['items'] as List)
            .map((e) => ShoppingItemLabel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _labelsCache = labels;
      _labelsCacheTimestamp = DateTime.now();
      debugPrint('getLabels response: ${labels.length} labels');
      return labels;
    } catch (e) {
      debugPrint('getLabels error: $e');
      return _labelsCache ?? [];
    }
  }

  /// POST /api/groups/labels - Erstellt ein neues Label
  Future<ShoppingItemLabel> createLabel({
    required String name,
    String color = '#E58325',
  }) async {
    debugPrint('POST /api/groups/labels: name=$name, color=$color');
    final response = await _dio.post(
      'api/groups/labels',
      data: {
        'name': name,
        'color': color,
      },
    );
    debugPrint('createLabel response: ${response.statusCode}');
    final created = ShoppingItemLabel.fromJson(response.data as Map<String, dynamic>);
    final cache = _labelsCache;
    if (cache != null) {
      _labelsCache = [...cache, created];
      _labelsCacheTimestamp = DateTime.now();
    }
    return created;
  }

  /// GET /api/groups/labels/{item_id} - Ruft ein einzelnes Label ab
  Future<ShoppingItemLabel> getLabel(String itemId) async {
    final response = await _dio.get('api/groups/labels/$itemId');
    return ShoppingItemLabel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/groups/labels/{item_id} - Aktualisiert ein Label
  Future<ShoppingItemLabel> updateLabel(
    String itemId, {
    required String name,
    String color = '#E58325',
  }) async {
    debugPrint('PUT /api/groups/labels/$itemId: name=$name, color=$color');
    final response = await _dio.put(
      'api/groups/labels/$itemId',
      data: {
        'name': name,
        'color': color,
      },
    );
    final updated = ShoppingItemLabel.fromJson(response.data as Map<String, dynamic>);
    final cache = _labelsCache;
    if (cache != null) {
      _labelsCache = cache.map((label) => label.id == updated.id ? updated : label).toList();
      _labelsCacheTimestamp = DateTime.now();
    }
    return updated;
  }

  /// DELETE /api/groups/labels/{item_id} - Löscht ein Label
  Future<void> deleteLabel(String itemId) async {
    debugPrint('DELETE /api/groups/labels/$itemId');
    await _dio.delete('api/groups/labels/$itemId');
    final cache = _labelsCache;
    if (cache != null) {
      _labelsCache = cache.where((label) => label.id != itemId).toList();
      _labelsCacheTimestamp = DateTime.now();
    }
  }

  /// Gets an existing label by name or creates a new one if it doesn't exist
  Future<ShoppingItemLabel> getOrCreateLabel(String name) async {
    // First, try to find existing label
    final labels = await getLabels();
    final existingLabel = labels.where(
      (l) => l.name.toLowerCase() == name.toLowerCase(),
    ).firstOrNull;

    if (existingLabel != null) {
      return existingLabel;
    }

    // If not found, create new label
    return createLabel(name: name);
  }
}
