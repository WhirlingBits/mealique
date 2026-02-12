import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import '../../data/sync/mealplan_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mealplan_model.dart';
import '../widgets/horizontal_date_picker.dart';
import '../widgets/add_meal_form.dart';

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
  late final ValueNotifier<List<MealplanEntry>> _selectedMeals;
  late Future<void> _mealplansFuture;

  // New state for entry type filtering
  PlanEntryType? _selectedEntryType;

  final MealplanRepository _mealplanRepository = MealplanRepository();
  final LinkedHashMap<DateTime, List<MealplanEntry>> _mealsByDay = LinkedHashMap(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    _selectedDay = today;

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    _dateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);

    _mealplansFuture = _fetchMealplans();
    _selectedMeals = ValueNotifier(_getMealsForDay(_selectedDay));
  }

  Future<void> _fetchMealplans() async {
    _mealsByDay.clear();
    final mealplans =
        await _mealplanRepository.getMealplans(_dateRange.start, _dateRange.end);
    if (mounted) {
      setState(() {
        _mealsByDay.addAll(mealplans);
        _selectedMeals.value = _getMealsForDay(_selectedDay);
        _selectedEntryType = null; // Reset filter
      });
    }
  }

  @override
  void dispose() {
    _selectedMeals.dispose();
    super.dispose();
  }

  List<MealplanEntry> _getMealsForDay(DateTime day) {
    return _mealsByDay[day] ?? [];
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDay = date;
      _selectedMeals.value = _getMealsForDay(date);
      _selectedEntryType = null; // Reset filter on day change
    });
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
      todayTextStyle:
          const TextStyle(color: accentColor, fontWeight: FontWeight.bold),
    );

    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 400),
      value: [_dateRange.start, _dateRange.end],
      borderRadius: BorderRadius.circular(15),
    );

    if (values != null &&
        values.length == 2 &&
        values[0] != null &&
        values[1] != null) {
      final newRange = DateTimeRange(start: values[0]!, end: values[1]!);
      setState(() {
        _dateRange = newRange;
        if (_selectedDay.isBefore(newRange.start) ||
            _selectedDay.isAfter(newRange.end)) {
          _selectedDay = newRange.start;
        }
        _mealplansFuture = _fetchMealplans();
      });
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Add functionality is not implemented yet.')),
            );
          },
        ),
      ),
    );
  }

  void _showEditMealDialog(MealplanEntry meal) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality is not implemented yet.')),
    );
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    //final l10n = AppLocalizations.of(context)!;
    String errorMessage;

    if (error is DioException && error.error is ApiException) {
      final apiError = error.error as ApiException;
      if (apiError is NetworkException) {
        errorMessage = 'Bitte prüfe deine Internetverbindung.'; // TODO: l10n
      } else if (apiError is ServerException) {
        errorMessage = 'Ein Serverfehler ist aufgetreten. Bitte versuche es später erneut.'; // TODO: l10n
      } else {
        errorMessage = apiError.message;
      }
    } else {
      errorMessage = 'Ein unerwarteter Fehler ist aufgetreten.'; // TODO: l10n
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Erneut versuchen'), // TODO: l10n
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTypeFilters() {
    return ValueListenableBuilder<List<MealplanEntry>>(
      valueListenable: _selectedMeals,
      builder: (context, meals, _) {
        final availableTypes = meals.map((m) => m.entryType).toSet().toList();
        availableTypes.sort((a, b) => a.index.compareTo(b.index));

        if (availableTypes.length < 2) {
          return const SizedBox.shrink();
        }

        List<Widget> chips = [
          ChoiceChip(
            label: const Text('All'),
            selected: _selectedEntryType == null,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedEntryType = null;
                });
              }
            },
          ),
        ];

        chips.addAll(availableTypes.map((type) {
          return ChoiceChip(
            label: Text(toBeginningOfSentenceCase(type.name) ?? type.name),
            selected: _selectedEntryType == type,
            onSelected: (selected) {
              setState(() {
                _selectedEntryType = selected ? type : null;
              });
            },
          );
        }));

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: chips
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: c,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final f = DateFormat.MMMd(l10n.localeName);
    final headerTitle =
        '${f.format(_dateRange.start)} - ${f.format(_dateRange.end)} ';
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
      body: FutureBuilder(
        future: _mealplansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error!, () {
              setState(() {
                _mealplansFuture = _fetchMealplans();
              });
            });
          }

          return Column(
            children: [
              HorizontalDatePicker(
                dateRange: _dateRange,
                selectedDate: _selectedDay,
                onDateChanged: _onDateChanged,
                selectedColor: accentColor,
                locale: l10n.localeName,
                mealsByDay: _mealsByDay,
              ),
              _buildEntryTypeFilters(), // Filter chips are added here
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
                      child: ValueListenableBuilder<List<MealplanEntry>>(
                        valueListenable: _selectedMeals,
                        builder: (context, meals, _) {
                          // Apply the filter
                          final filteredMeals = _selectedEntryType == null
                              ? meals
                              : meals
                                  .where((m) => m.entryType == _selectedEntryType)
                                  .toList();

                          if (filteredMeals.isEmpty) {
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
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: filteredMeals.length,
                              itemBuilder: (context, index) {
                                final meal = filteredMeals[index];
                                return Slidable(
                                  key: ObjectKey(meal.id),
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) =>
                                            _showEditMealDialog(meal),
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          // TODO: Implement deletion
                                        },
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    margin:
                                        const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(meal.recipe?.name ??
                                          meal.title ??
                                          'Untitled Meal'),
                                      leading: Text(
                                          toBeginningOfSentenceCase(
                                                  meal.entryType.name) ??
                                              '',
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
          );
        },
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
