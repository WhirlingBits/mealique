import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mealique/data/remote/dio_client.dart';
import 'package:mealique/models/shopping_item_model.dart';
import '../local/token_storage.dart';

/// API-Client für Shopping-Labels (Kategorien wie "Obst & Gemüse", "Milch & Käse", etc.)
class LabelsApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

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

  /// GET /api/groups/labels - Ruft alle Labels ab
  Future<List<ShoppingItemLabel>> getLabels() async {
    try {
      final response = await _dio.get('api/groups/labels');
      debugPrint('getLabels response: ${response.data}');

      if (response.data is List) {
        return (response.data as List)
            .map((e) => ShoppingItemLabel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map && response.data['items'] is List) {
        return (response.data['items'] as List)
            .map((e) => ShoppingItemLabel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('getLabels error: $e');
      return [];
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
    return ShoppingItemLabel.fromJson(response.data as Map<String, dynamic>);
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
    return ShoppingItemLabel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/groups/labels/{item_id} - Löscht ein Label
  Future<void> deleteLabel(String itemId) async {
    debugPrint('DELETE /api/groups/labels/$itemId');
    await _dio.delete('api/groups/labels/$itemId');
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
