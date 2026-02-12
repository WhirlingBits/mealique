import 'dart:collection';

import '../../models/mealplan_model.dart';
import '../remote/household_api.dart';

class MealplanRepository {
  final HouseholdApi _api;

  MealplanRepository() : _api = HouseholdApi();

  Future<LinkedHashMap<DateTime, List<MealplanEntry>>> getMealplans(
      DateTime start, DateTime end) async {
    // API call now filters by date, and perPage: -1 fetches all entries in the range.
    final mealplanResponse = await _api.getMealplans(1, -1, startDate: start, endDate: end);
    final items = mealplanResponse.items;

    final LinkedHashMap<DateTime, List<MealplanEntry>> mealsByDay = LinkedHashMap(
      equals: (a, b) => a.year == b.year && a.month == b.month && a.day == b.day,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    for (var item in items) {
      // Use DateTime.parse for robust ISO 8601 date parsing.
      final localDate = DateTime.parse(item.date).toLocal();
      // Normalize to UTC midnight to use as a key for the map.
      final dayKey = DateTime.utc(localDate.year, localDate.month, localDate.day);
      
      if (mealsByDay.containsKey(dayKey)) {
        mealsByDay[dayKey]!.add(item);
      } else {
        mealsByDay[dayKey] = [item];
      }
    }
    return mealsByDay;
  }
}
