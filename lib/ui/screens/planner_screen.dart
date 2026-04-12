import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:mealique/core/utils/responsive_utils.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import '../widgets/planner_actions_menu.dart';
import '../../data/sync/mealplan_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mealplan_model.dart';
import '../widgets/horizontal_date_picker.dart';
import '../widgets/add_meal_form.dart';
import 'recipe_detail_screen.dart';

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
    try {
      final mealplans =
          await _mealplanRepository.getMealplans(_dateRange.start, _dateRange.end);
      if (mounted) {
        setState(() {
          _mealsByDay.addAll(mealplans);
          _selectedMeals.value = _getMealsForDay(_selectedDay);
          _selectedEntryType = null; // Reset filter
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch mealplans: $e');
      if (mounted) {
        setState(() {
          _selectedMeals.value = _getMealsForDay(_selectedDay);
          _selectedEntryType = null;
        });
      }
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
    final mealsForDay = _getMealsForDay(_selectedDay);
    final occupiedTypes = mealsForDay.map((m) => m.entryType).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddMealForm(
          selectedDate: _selectedDay,
          occupiedEntryTypes: occupiedTypes,
          onAddMeal: (entryType, recipe) async {
            final l10n = AppLocalizations.of(context)!;
            final dateStr = _selectedDay.toIso8601String().split('T').first;

            final entry = MealplanEntry(
              id: 0,
              date: dateStr,
              entryType: entryType,
              title: recipe.name,
              recipeId: recipe.id.isNotEmpty ? recipe.id : null,
            );

            try {
              await _mealplanRepository.createMealplan(entry);
              if (mounted) {
                setState(() {
                  _mealplansFuture = _fetchMealplans();
                });
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.mealAddedSuccess(recipe.name)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorCreating(e.toString())),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 4),
                    ),
                  );
              }
            }
          },
        ),
      ),
    );
  }

  void _showEditMealDialog(MealplanEntry meal) {
    final l10n = AppLocalizations.of(context)!;
    final mealsForDay = _getMealsForDay(_selectedDay);
    final occupiedTypes = mealsForDay.map((m) => m.entryType).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddMealForm(
          selectedDate: _selectedDay,
          occupiedEntryTypes: occupiedTypes,
          editingEntryType: meal.entryType,
          onAddMeal: (entryType, recipe) async {
            final dateStr = _selectedDay.toIso8601String().split('T').first;

            final updatedEntry = MealplanEntry(
              id: meal.id,
              date: dateStr,
              entryType: entryType,
              title: recipe.name,
              recipeId: recipe.id.isNotEmpty ? recipe.id : null,
              groupId: meal.groupId,
              householdId: meal.householdId,
            );

            try {
              await _mealplanRepository.updateMealplan(meal.id, updatedEntry);
              if (mounted) {
                setState(() {
                  _mealplansFuture = _fetchMealplans();
                });
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.mealUpdatedSuccess),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorCreating(e.toString())),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 4),
                    ),
                  );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteMeal(MealplanEntry meal) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteMeal),
        content: Text(l10n.confirmDeleteMeal(meal.recipe?.name ?? meal.title ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _mealplanRepository.deleteMealplan(meal.id);
      if (mounted) {
        setState(() {
          _mealplansFuture = _fetchMealplans();
        });
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.mealDeletedSuccess),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.errorCreating(e.toString())),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    }
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context)!;
    String errorMessage;
    if (error is DioException && error.error is ApiException) {
      final apiError = error.error as ApiException;
      errorMessage = apiError.message;
    } else {
      errorMessage = l10n.unexpectedError;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.tryAgain),
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
            label: Text(AppLocalizations.of(context)!.all),
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
    const accentColor = Color(0xFFE58325);
    final isTablet = ResponsiveUtils.isLargeTablet(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: Text(l10n.planner),
        actions: [
          PlannerActionsMenu(
            onAddMeal: () => _showAddMealSheet(),
            onRefresh: () {
              setState(() {
                _mealplansFuture = _fetchMealplans();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
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

          if (isTablet) {
            return _buildTabletLayout(context, l10n, accentColor);
          }
          return _buildPhoneLayout(context, l10n, accentColor);
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

  /// Phone Layout: Vertical calendar and meal list
  Widget _buildPhoneLayout(BuildContext context, AppLocalizations l10n, Color accentColor) {
    final f = DateFormat.MMMd(l10n.localeName);
    final headerTitle = '${f.format(_dateRange.start)} - ${f.format(_dateRange.end)} ';

    return Column(
      children: [
        _buildDateRangeHeader(headerTitle, accentColor),
        HorizontalDatePicker(
          dateRange: _dateRange,
          selectedDate: _selectedDay,
          onDateChanged: _onDateChanged,
          selectedColor: accentColor,
          locale: l10n.localeName,
          mealsByDay: _mealsByDay,
        ),
        _buildEntryTypeFilters(),
        const Divider(height: 1),
        Expanded(child: _buildMealsList(context, l10n, accentColor)),
      ],
    );
  }

  /// Tablet Layout: Side-by-side calendar and meal list
  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n, Color accentColor) {
    final f = DateFormat.MMMd(l10n.localeName);
    final headerTitle = '${f.format(_dateRange.start)} - ${f.format(_dateRange.end)} ';
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return Row(
      children: [
        // Left: Calendar Section
        SizedBox(
          width: 320,
          child: Column(
            children: [
              _buildDateRangeHeader(headerTitle, accentColor),
              // Vertical calendar for tablet
              Expanded(
                child: _buildVerticalDateList(context, l10n, accentColor),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right: Meals List
        Expanded(
          child: Column(
            children: [
              _buildEntryTypeFilters(),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding - 16),
                  child: _buildMealsList(context, l10n, accentColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeHeader(String headerTitle, Color accentColor) {
    return InkWell(
      onTap: _showDateRangePicker,
      child: Container(
        width: double.infinity,
        color: accentColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(headerTitle, style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: accentColor),
          ],
        ),
      ),
    );
  }

  /// Vertical date list for tablet layout
  Widget _buildVerticalDateList(BuildContext context, AppLocalizations l10n, Color accentColor) {
    final days = <DateTime>[];
    var current = _dateRange.start;
    while (!current.isAfter(_dateRange.end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isSelected = isSameDay(day, _selectedDay);
        final mealsForDay = _getMealsForDay(day);
        final hasMeals = mealsForDay.isNotEmpty;

        return InkWell(
          onTap: () => _onDateChanged(day),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.15) : null,
              border: Border(
                left: BorderSide(
                  color: isSelected ? accentColor : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.E(l10n.localeName).format(day),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? accentColor : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? accentColor : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasMeals)
                        ...mealsForDay.take(3).map((meal) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                meal.recipe?.name ?? meal.title ?? l10n.untitledMeal,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                      else
                        Text(
                          l10n.noMealsPlanned,
                          style: TextStyle(fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                      if (mealsForDay.length > 3)
                        Text(
                          '+${mealsForDay.length - 3} more',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                if (hasMeals)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${mealsForDay.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealsList(BuildContext context, AppLocalizations l10n, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            DateFormat.yMMMEd(l10n.localeName).format(_selectedDay),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<MealplanEntry>>(
            valueListenable: _selectedMeals,
            builder: (context, meals, _) {
              final filteredMeals = _selectedEntryType == null
                  ? meals
                  : meals.where((m) => m.entryType == _selectedEntryType).toList();

              if (filteredMeals.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noMealsPlanned,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                );
              }
              return SlidableAutoCloseBehavior(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredMeals.length,
                  itemBuilder: (context, index) {
                    final meal = filteredMeals[index];
                    return Slidable(
                      key: ObjectKey(meal.id),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) => _showEditMealDialog(meal),
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: l10n.edit,
                          ),
                          SlidableAction(
                            onPressed: (context) => _deleteMeal(meal),
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: l10n.delete,
                          ),
                        ],
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(meal.recipe?.name ?? meal.title ?? l10n.untitledMeal),
                          leading: Text(
                              toBeginningOfSentenceCase(meal.entryType.name) ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: meal.recipeId != null
                              ? const Icon(Icons.chevron_right, color: Colors.grey)
                              : null,
                          onTap: meal.recipeId != null && meal.recipe?.slug != null
                              ? () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => RecipeDetailScreen(
                                      recipeSlug: meal.recipe!.slug,
                                    ),
                                  );
                                }
                              : null,
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
    );
  }
}
