import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/core/utils/offline_helper.dart';
import 'package:mealique/data/local/household_storage.dart';
import 'package:mealique/data/local/sync_queue_storage.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/models/mealplan_model.dart';
import '../remote/household_api.dart';

class MealplanRepository {
  final HouseholdApi _api;
  final HouseholdStorage _storage;
  final TokenStorage _tokenStorage;
  final SyncQueueStorage _syncQueue;

  MealplanRepository() 
      : _api = HouseholdApi(),
        _storage = HouseholdStorage(),
        _tokenStorage = TokenStorage(),
        _syncQueue = SyncQueueStorage();

  /// Helper to group a flat list of MealplanEntry into a LinkedHashMap by day.
  LinkedHashMap<DateTime, List<MealplanEntry>> _groupByDay(List<MealplanEntry> items) {
    final LinkedHashMap<DateTime, List<MealplanEntry>> mealsByDay = LinkedHashMap(
      equals: (a, b) => a.year == b.year && a.month == b.month && a.day == b.day,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    for (var item in items) {
      final localDate = DateTime.parse(item.date).toLocal();
      final dayKey = DateTime.utc(localDate.year, localDate.month, localDate.day);
      
      if (mealsByDay.containsKey(dayKey)) {
        mealsByDay[dayKey]!.add(item);
      } else {
        mealsByDay[dayKey] = [item];
      }
    }
    return mealsByDay;
  }

  Future<LinkedHashMap<DateTime, List<MealplanEntry>>> getMealplans(
      DateTime start, DateTime end) async {
    final token = await _tokenStorage.getToken();

    if (token == AppConstants.demoToken) {
      return _getDemoMealplans(start, end);
    }

    return withOfflineFallbackSimple<LinkedHashMap<DateTime, List<MealplanEntry>>>(
      apiCall: () async {
        final mealplanResponse = await _api.getMealplans(1, -1, startDate: start, endDate: end);
        final items = mealplanResponse.items;
        return _groupByDay(items);
      },
      cacheWrite: (mealsByDay) async {
        // Flatten and save all entries; clear old data for this date range first
        final allEntries = mealsByDay.values.expand((list) => list).toList();
        debugPrint('Mealplans cacheWrite: ${allEntries.length} entries for ${mealsByDay.keys.length} days');
        try {
          await _storage.clearMealplans();
          if (allEntries.isNotEmpty) {
            await _storage.saveMealplans(allEntries);
          }
          debugPrint('Mealplans cacheWrite: saved successfully');
        } catch (e) {
          debugPrint('Mealplans cacheWrite error: $e');
        }
      },
      cacheRead: () async {
        final cached = await _storage.getMealplans();
        debugPrint('Mealplans cacheRead: ${cached?.length ?? 0} entries in cache');
        if (cached == null || cached.isEmpty) return null;

        // Filter by date range client-side
        final startUtc = DateTime.utc(start.year, start.month, start.day);
        final endUtc = DateTime.utc(end.year, end.month, end.day);

        final filtered = cached.where((entry) {
          try {
            final entryDate = DateTime.parse(entry.date).toLocal();
            final entryDayUtc = DateTime.utc(entryDate.year, entryDate.month, entryDate.day);
            return !entryDayUtc.isBefore(startUtc) && !entryDayUtc.isAfter(endUtc);
          } catch (e) {
            return false;
          }
        }).toList();

        if (filtered.isEmpty) return null;
        return _groupByDay(filtered);
      },
    );
  }

  Future<MealplanEntry> createMealplan(MealplanEntry entry) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      final demoEntry = MealplanEntry(
        id: DateTime.now().millisecondsSinceEpoch,
        date: entry.date,
        entryType: entry.entryType,
        title: entry.title,
        recipeId: entry.recipeId,
        recipe: entry.recipe,
      );
      return demoEntry;
    }

    final localEntry = MealplanEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      date: entry.date,
      entryType: entry.entryType,
      title: entry.title,
      recipeId: entry.recipeId,
      recipe: entry.recipe,
      groupId: entry.groupId,
      householdId: entry.householdId,
    );

    try {
      final result = await _api.createMealplan(entry);
      // Also save to local cache
      try {
        await _storage.saveMealplans([result]);
      } catch (_) {}
      return result;
    } catch (e) {
      if (_isOfflineError(e)) {
        try {
          await _storage.saveMealplans([localEntry]);
        } catch (storageError) {
          debugPrint('Failed to save mealplan locally: $storageError');
        }
        // Enqueue for sync when back online
        try {
          await _syncQueue.enqueue(
            actionType: 'create',
            entityType: 'mealplan',
            payload: entry.toJson(),
          );
        } catch (queueError) {
          debugPrint('Failed to enqueue mealplan create: $queueError');
        }
        debugPrint('Mealplan saved locally + enqueued (offline)');
        return localEntry;
      }
      rethrow;
    }
  }

  Future<MealplanEntry> updateMealplan(int itemId, MealplanEntry entry) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return entry;
    }

    try {
      final result = await _api.updateMealplan(itemId, entry);
      // Update local cache
      try {
        await _storage.saveMealplans([result]);
      } catch (_) {}
      return result;
    } catch (e) {
      if (_isOfflineError(e)) {
        // Update locally
        try {
          await _storage.saveMealplans([entry]);
        } catch (storageError) {
          debugPrint('Failed to update mealplan locally: $storageError');
        }
        // Enqueue for sync when back online
        try {
          await _syncQueue.enqueue(
            actionType: 'update',
            entityType: 'mealplan',
            entityId: itemId.toString(),
            payload: entry.toJson(),
          );
        } catch (queueError) {
          debugPrint('Failed to enqueue mealplan update: $queueError');
        }
        debugPrint('Mealplan updated locally + enqueued (offline)');
        return entry;
      }
      rethrow;
    }
  }

  Future<void> deleteMealplan(int itemId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;

    try {
      await _api.deleteMealplan(itemId);
    } catch (e) {
      if (!_isOfflineError(e)) rethrow;
      // Enqueue for sync when back online
      try {
        await _syncQueue.enqueue(
          actionType: 'delete',
          entityType: 'mealplan',
          entityId: itemId.toString(),
          payload: {'id': itemId},
        );
      } catch (queueError) {
        debugPrint('Failed to enqueue mealplan delete: $queueError');
      }
      debugPrint('Mealplan delete enqueued (offline)');
    }
    // Remove from local cache regardless (both online and offline)
    try {
      final cached = await _storage.getMealplans();
      if (cached != null) {
        final remaining = cached.where((m) => m.id != itemId).toList();
        await _storage.clearMealplans();
        if (remaining.isNotEmpty) {
          await _storage.saveMealplans(remaining);
        }
      }
    } catch (e) {
      debugPrint('Failed to remove mealplan from local cache: $e');
    }
  }

  /// Check if an error indicates the device is offline.
  bool _isOfflineError(Object e) {
    if (e is DioException) {
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
    if (e is NetworkException) return true;
    final msg = e.toString().toLowerCase();
    return msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('timeout');
  }

  // Helper for demo data
  LinkedHashMap<DateTime, List<MealplanEntry>> _getDemoMealplans(DateTime start, DateTime end) {
    final today = DateTime.now();
    final dayKey = DateTime.utc(today.year, today.month, today.day);
    final demoData = LinkedHashMap<DateTime, List<MealplanEntry>>(
      equals: (a, b) => a.year == b.year && a.month == b.month && a.day == b.day,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    // Only add data if 'today' is within the requested range
    if (!today.isBefore(start) && !today.isAfter(end)) {
        demoData[dayKey] = [
        MealplanEntry(
          id: 1,
          date: today.toIso8601String(),
          entryType: PlanEntryType.breakfast,
          title: 'Pancakes',
          recipe: MealplanRecipe(id: '3', name: 'Fluffy Pancakes', slug: 'fluffy-pancakes'),
        ),
        MealplanEntry(
          id: 2,
          date: today.toIso8601String(),
          entryType: PlanEntryType.lunch,
          title: 'Chicken Salad',
          recipe: MealplanRecipe(id: '4', name: 'Classic Chicken Salad', slug: 'classic-chicken-salad'),
        ),
         MealplanEntry(
          id: 3,
          date: today.toIso8601String(),
          entryType: PlanEntryType.dinner,
          title: 'Pasta Bolognese',
          recipe: MealplanRecipe(id: '1', name: 'Pasta Bolognese', slug: 'pasta-bolognese'),
        ),
      ];
    }
    
    return demoData;
  }
}
