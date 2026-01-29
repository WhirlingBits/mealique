import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/horizontal_date_picker.dart';
import '../widgets/add_meal_form.dart';

// Ein einfaches Datenmodell für eine geplante Mahlzeit.
class Meal {
  final String type;
  final String name;

  Meal({required this.type, required this.name});

  @override
  String toString() => name;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTimeRange _dateRange;
  late DateTime _selectedDay;
  late final ValueNotifier<List<Meal>> _selectedMeals;

  final LinkedHashMap<DateTime, List<Meal>> _mealsByDay = LinkedHashMap(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    _selectedDay = today;
    _dateRange = DateTimeRange(start: today, end: today.add(const Duration(days: 6)));

    _populateDummyData();
    _selectedMeals = ValueNotifier(_getMealsForDay(_selectedDay));
  }

  void _populateDummyData() {
    final today = DateTime.now();
    final day1 = DateTime.utc(today.year, today.month, today.day);
    final day2 = DateTime.utc(today.year, today.month, today.day + 2);

    _mealsByDay[day1] = [
      Meal(type: 'Frühstück', name: 'Müsli'),
      Meal(type: 'Abendessen', name: 'Pizza'),
    ];
    _mealsByDay[day2] = [
      Meal(type: 'Mittagessen', name: 'Großer Salat'),
    ];
  }

  @override
  void dispose() {
    _selectedMeals.dispose();
    super.dispose();
  }

  List<Meal> _getMealsForDay(DateTime day) {
    return _mealsByDay[day] ?? [];
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDay = date;
    });
    _selectedMeals.value = _getMealsForDay(date);
  }

  Future<void> _showDateRangePicker() async {
    const accentColor = Color(0xFFE58325);
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: accentColor,
      weekdayLabelTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      controlsTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      dayTextStyle: const TextStyle(),
      selectedDayTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      todayTextStyle: const TextStyle(color: accentColor, fontWeight: FontWeight.bold),
    );

    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 400),
      value: [_dateRange.start, _dateRange.end],
      borderRadius: BorderRadius.circular(15),
    );

    if (values != null && values.length == 2 && values[0] != null && values[1] != null) {
      final newRange = DateTimeRange(start: values[0]!, end: values[1]!);
      setState(() {
        _dateRange = newRange;
        if (_selectedDay.isBefore(newRange.start) ||
            _selectedDay.isAfter(newRange.end)) {
          _selectedDay = newRange.start;
        }
      });
      _selectedMeals.value = _getMealsForDay(_selectedDay);
    }
  }

  void _showAddMealSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddMealForm(
          onAddMeal: (mealType, recipe) {
            final newMeal = Meal(type: mealType, name: recipe.name);
            setState(() {
              if (_mealsByDay[_selectedDay] != null) {
                _mealsByDay[_selectedDay]!.add(newMeal);
              } else {
                _mealsByDay[_selectedDay] = [newMeal];
              }
            });
            _selectedMeals.value = _getMealsForDay(_selectedDay);
          },
        ),
      ),
    );
  }

  void _showEditMealDialog(Meal meal) {
    // TODO: Implement a proper edit dialog/sheet, potentially reusing AddMealForm
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bearbeiten-Funktion ist noch nicht implementiert.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final f = DateFormat.MMMd(l10n.localeName);
    final headerTitle =
        '${f.format(_dateRange.start)} - ${f.format(_dateRange.end)}';
    const accentColor = Color(0xFFE58325);

    return Scaffold(
      appBar: AppBar(
        title: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showDateRangePicker,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(headerTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          HorizontalDatePicker(
            dateRange: _dateRange,
            selectedDate: _selectedDay,
            onDateChanged: _onDateChanged,
            selectedColor: accentColor,
            locale: l10n.localeName,
            mealsByDay: _mealsByDay,
          ),
          const Divider(height: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    DateFormat.yMMMEd(l10n.localeName).format(_selectedDay),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<Meal>>(
                    valueListenable: _selectedMeals,
                    builder: (context, meals, _) {
                      if (meals.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noMealsPlanned,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        );
                      }
                      return SlidableAutoCloseBehavior(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: meals.length,
                          itemBuilder: (context, index) {
                            final meal = meals[index];
                            return Slidable(
                              key: ObjectKey(meal),
                              startActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) => _showEditMealDialog(meal),
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Bearbeiten',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      setState(() {
                                        _mealsByDay[_selectedDay]?.remove(meal);
                                        _selectedMeals.value = _getMealsForDay(_selectedDay);
                                      });
                                    },
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Löschen',
                                  ),
                                ],
                              ),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(meal.name),
                                  leading: Text(meal.type,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMealSheet,
        tooltip: l10n.addMeal,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
