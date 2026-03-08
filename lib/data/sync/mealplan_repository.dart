import 'dart:collection';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/models/mealplan_model.dart';
import '../remote/household_api.dart';

class MealplanRepository {
  final HouseholdApi _api;
  final TokenStorage _tokenStorage;

  MealplanRepository() 
      : _api = HouseholdApi(),
        _tokenStorage = TokenStorage();

  Future<LinkedHashMap<DateTime, List<MealplanEntry>>> getMealplans(
      DateTime start, DateTime end) async {
    final token = await _tokenStorage.getToken();

    // --- DEMO DATA LOGIC ---
    if (token == AppConstants.demoToken) {
      return _getDemoMealplans(start, end);
    }
    // --- END DEMO DATA LOGIC ---

    final mealplanResponse = await _api.getMealplans(1, -1, startDate: start, endDate: end);
    final items = mealplanResponse.items;

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
    return await _api.createMealplan(entry);
  }

  Future<MealplanEntry> updateMealplan(int itemId, MealplanEntry entry) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return entry;
    }
    return await _api.updateMealplan(itemId, entry);
  }

  Future<void> deleteMealplan(int itemId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;
    await _api.deleteMealplan(itemId);
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
