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

  // ─── Demo-Daten für den Planner (ganze Woche) ────────────────────────────

  /// Statische Tages-Vorlage: Index 0 = Montag … 6 = Sonntag.
  static const List<List<_DemoMeal>> _weekTemplate = [
    // Montag
    [
      _DemoMeal(PlanEntryType.breakfast, 'Overnight Oats',      '101', 'overnight-oats'),
      _DemoMeal(PlanEntryType.lunch,     'Tomatensuppe',        '102', 'tomatensuppe'),
      _DemoMeal(PlanEntryType.dinner,    'Pasta Bolognese',     '103', 'pasta-bolognese'),
    ],
    // Dienstag
    [
      _DemoMeal(PlanEntryType.breakfast, 'Rührei mit Toast',    '104', 'ruehrei-toast'),
      _DemoMeal(PlanEntryType.snack,     'Apfel & Nüsse',       '105', 'apfel-nuesse'),
      _DemoMeal(PlanEntryType.dinner,    'Hähnchen-Curry',      '106', 'haehnchen-curry'),
    ],
    // Mittwoch
    [
      _DemoMeal(PlanEntryType.breakfast, 'Müsli mit Beeren',    '107', 'muesli-beeren'),
      _DemoMeal(PlanEntryType.lunch,     'Caesar Salad',        '108', 'caesar-salad'),
      _DemoMeal(PlanEntryType.dinner,    'Lachs mit Gemüse',    '109', 'lachs-gemuese'),
    ],
    // Donnerstag
    [
      _DemoMeal(PlanEntryType.breakfast, 'Pancakes',            '110', 'fluffy-pancakes'),
      _DemoMeal(PlanEntryType.lunch,     'Chicken Wrap',        '111', 'chicken-wrap'),
      _DemoMeal(PlanEntryType.dinner,    'Pizza Margherita',    '112', 'pizza-margherita'),
    ],
    // Freitag
    [
      _DemoMeal(PlanEntryType.breakfast, 'Avocado Toast',       '113', 'avocado-toast'),
      _DemoMeal(PlanEntryType.snack,     'Smoothie Bowl',       '114', 'smoothie-bowl'),
      _DemoMeal(PlanEntryType.dinner,    'Spaghetti Carbonara', '115', 'spaghetti-carbonara'),
    ],
    // Samstag
    [
      _DemoMeal(PlanEntryType.breakfast, 'Französische Crepes', '116', 'french-crepes'),
      _DemoMeal(PlanEntryType.lunch,     'Burger mit Salat',    '117', 'burger-salat'),
      _DemoMeal(PlanEntryType.dinner,    'Rinderbraten',        '118', 'rinderbraten'),
      _DemoMeal(PlanEntryType.dessert,   'Tiramisu',            '119', 'tiramisu'),
    ],
    // Sonntag
    [
      _DemoMeal(PlanEntryType.breakfast, 'Eggs Benedict',       '120', 'eggs-benedict'),
      _DemoMeal(PlanEntryType.lunch,     'Gemüsecurry',         '121', 'gemuesecurry'),
      _DemoMeal(PlanEntryType.dinner,    'Roastbeef',           '122', 'roastbeef'),
    ],
  ];

  LinkedHashMap<DateTime, List<MealplanEntry>> _getDemoMealplans(
      DateTime start, DateTime end) {
    final demoData = LinkedHashMap<DateTime, List<MealplanEntry>>(
      equals: (a, b) =>
          a.year == b.year && a.month == b.month && a.day == b.day,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    // Alle Tage im angefragten Bereich befüllen
    DateTime current = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day);
    int idCounter = 1;

    while (!current.isAfter(endUtc)) {
      // weekday: 1=Mo … 7=So  →  Index 0–6
      final idx = current.weekday - 1;
      final meals = _weekTemplate[idx];
      final dateStr = current.toIso8601String();

      demoData[current] = meals.map((m) {
        return MealplanEntry(
          id: idCounter++,
          date: dateStr,
          entryType: m.type,
          title: m.title,
          recipe: MealplanRecipe(id: m.recipeId, name: m.title, slug: m.slug),
        );
      }).toList();

      current = current.add(const Duration(days: 1));
    }

    return demoData;
  }
}

/// Einfacher Daten-Container für die Demo-Wochenvorlage.
class _DemoMeal {
  final PlanEntryType type;
  final String title;
  final String recipeId;
  final String slug;

  const _DemoMeal(this.type, this.title, this.recipeId, this.slug);
}

