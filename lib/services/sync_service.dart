import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mealique/data/local/sync_queue_storage.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/remote/household_api.dart';
import 'package:mealique/models/mealplan_model.dart';
import 'package:mealique/models/shopping_item_model.dart';

/// Service that processes the offline sync queue when the device regains
/// network connectivity. It replays every pending write operation against
/// the Mealie API in FIFO order.
class SyncService {
  // ── singleton ──────────────────────────────────────────────────────
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SyncQueueStorage _queue = SyncQueueStorage();
  final HouseholdApi _api = HouseholdApi();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Whether a sync is currently running (prevents concurrent runs).
  bool _isSyncing = false;

  /// Notifies listeners about the number of pending operations.
  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  /// Call once at app startup (e.g. in main or MainScreen.initState).
  void init() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline) {
        processQueue();
      }
    });
    // Also try to sync immediately in case we start online with a backlog.
    _refreshCount();
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  /// Process all pending operations in order.
  /// Returns the number of operations that were successfully synced.
  Future<int> processQueue() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    int synced = 0;
    try {
      final ops = await _queue.getAll();
      if (ops.isEmpty) {
        _isSyncing = false;
        await _refreshCount();
        return 0;
      }

      debugPrint('SyncService: processing ${ops.length} pending operations');

      for (final op in ops) {
        try {
          await _replayOperation(
            actionType: op.actionType,
            entityType: op.entityType,
            entityId: op.entityId,
            payload: json.decode(op.payload) as Map<String, dynamic>,
          );
          // Success – remove from queue
          await _queue.remove(op.id);
          synced++;
          debugPrint('SyncService: synced op #${op.id} (${ op.actionType} ${op.entityType})');
        } on DioException catch (e) {
          if (_isNetworkError(e)) {
            // Still offline → stop processing, retry later
            debugPrint('SyncService: still offline, stopping queue processing');
            break;
          }
          // Non-recoverable API error (4xx) → remove and log
          debugPrint('SyncService: dropping op #${op.id} due to API error: ${e.response?.statusCode} ${e.response?.data}');
          await _queue.remove(op.id);
        } catch (e) {
          if (_isLikelyNetworkError(e)) {
            debugPrint('SyncService: likely still offline, stopping');
            break;
          }
          // Unknown error → remove to avoid infinite loops
          debugPrint('SyncService: dropping op #${op.id} due to error: $e');
          await _queue.remove(op.id);
        }
      }
    } finally {
      _isSyncing = false;
      await _refreshCount();
    }

    return synced;
  }

  /// Clear the queue (e.g. on logout).
  Future<void> clearQueue() async {
    await _queue.clearAll();
    await _refreshCount();
  }

  // ── operation replay ───────────────────────────────────────────────

  Future<void> _replayOperation({
    required String actionType,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> payload,
  }) async {
    switch (entityType) {
      case 'shopping_list':
        await _replayShoppingList(actionType, entityId, payload);
        break;
      case 'shopping_item':
        await _replayShoppingItem(actionType, entityId, payload);
        break;
      case 'mealplan':
        await _replayMealplan(actionType, entityId, payload);
        break;
      default:
        debugPrint('SyncService: unknown entityType "$entityType"');
    }
  }

  Future<void> _replayShoppingList(
      String action, String? entityId, Map<String, dynamic> payload) async {
    switch (action) {
      case 'create':
        await _api.createShoppingList(name: payload['name'] as String);
        break;
      case 'update':
        if (entityId == null) return;
        // Fetch current list, update name, push back
        final current = await _api.getShoppingList(entityId);
        final updated = current.copyWith(name: payload['name'] as String);
        await _api.updateShoppingList(entityId, updated);
        break;
      case 'delete':
        if (entityId == null) return;
        try {
          await _api.deleteShoppingList(entityId);
        } on DioException catch (e) {
          // 404 means it's already gone – that's fine
          if (e.response?.statusCode == 404) return;
          rethrow;
        }
        break;
    }
  }

  Future<void> _replayShoppingItem(
      String action, String? entityId, Map<String, dynamic> payload) async {
    switch (action) {
      case 'create':
        final item = ShoppingItem.fromJson(payload);
        // Make sure id is empty so toJson() produces a creation payload
        final createItem = item.copyWith(id: '');
        await _api.createShoppingItem(createItem);
        break;
      case 'update':
        if (entityId == null) return;
        final item = ShoppingItem.fromJson(payload);
        await _api.updateShoppingItem(entityId, item);
        break;
      case 'delete':
        if (entityId == null) return;
        try {
          await _api.deleteShoppingItem(entityId);
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) return;
          rethrow;
        }
        break;
    }
  }

  Future<void> _replayMealplan(
      String action, String? entityId, Map<String, dynamic> payload) async {
    switch (action) {
      case 'create':
        final entry = MealplanEntry.fromJson(payload);
        // Set id to 0 so toJson() treats it as a new entry
        final createEntry = MealplanEntry(
          id: 0,
          date: entry.date,
          entryType: entry.entryType,
          title: entry.title,
          text: entry.text,
          recipeId: entry.recipeId,
          groupId: entry.groupId,
          householdId: entry.householdId,
        );
        await _api.createMealplan(createEntry);
        break;
      case 'update':
        if (entityId == null) return;
        final itemId = int.tryParse(entityId);
        if (itemId == null) return;
        final entry = MealplanEntry.fromJson(payload);
        await _api.updateMealplan(itemId, entry);
        break;
      case 'delete':
        if (entityId == null) return;
        final itemId = int.tryParse(entityId);
        if (itemId == null) return;
        try {
          await _api.deleteMealplan(itemId);
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) return;
          rethrow;
        }
        break;
    }
  }

  // ── helpers ────────────────────────────────────────────────────────

  Future<void> _refreshCount() async {
    pendingCount.value = await _queue.count();
  }

  bool _isNetworkError(DioException e) {
    if (e.error is NetworkException) return true;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.unknown:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }

  bool _isLikelyNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('timeout');
  }
}

