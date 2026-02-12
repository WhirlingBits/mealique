import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealique/models/mealplan_model.dart';

class HorizontalDatePicker extends StatefulWidget {
  final DateTimeRange dateRange;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final Color selectedColor;
  final String locale;
  final Map<DateTime, List<MealplanEntry>> mealsByDay;

  const HorizontalDatePicker({
    super.key,
    required this.dateRange,
    required this.selectedDate,
    required this.onDateChanged,
    required this.selectedColor,
    required this.locale,
    required this.mealsByDay,
  });

  @override
  State<HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  late ScrollController _scrollController;
  static const double _kItemWidth = 68.0; // 60 width + 8 horizontal margin

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll to the initial date after the layout is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToDate(widget.selectedDate);
      }
    });
  }

  @override
  void didUpdateWidget(HorizontalDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the date range or selected date changes from the outside, scroll to the new selection.
    if (!_isSameDay(widget.selectedDate, oldWidget.selectedDate) ||
        widget.dateRange != oldWidget.dateRange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToDate(widget.selectedDate);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _scrollToDate(DateTime date) {
    final targetDate = DateTime.utc(date.year, date.month, date.day);
    final startDate =
        DateTime.utc(widget.dateRange.start.year, widget.dateRange.start.month, widget.dateRange.start.day);

    final int index = targetDate.difference(startDate).inDays;
    final dayCount = widget.dateRange.duration.inDays;

    if (_scrollController.hasClients && index >= 0 && index <= dayCount) {
      _scrollController.animateTo(
        index * _kItemWidth,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildIndicator(bool hasMeal, bool isSelected) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasMeal
            ? (isSelected ? Colors.white : widget.selectedColor)
            : (isSelected ? widget.selectedColor.withOpacity(0.5) : Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayCount = widget.dateRange.duration.inDays + 1;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dayCount,
        itemBuilder: (context, index) {
          final date = widget.dateRange.start.add(Duration(days: index));
          final isSelected = _isSameDay(date, widget.selectedDate);
          final mealsForDay = widget.mealsByDay[date] ?? [];

          final hasBreakfast = mealsForDay.any((m) => m.entryType == PlanEntryType.breakfast);
          final hasLunch = mealsForDay.any((m) => m.entryType == PlanEntryType.lunch);
          final hasDinner = mealsForDay.any((m) => m.entryType == PlanEntryType.dinner);

          return GestureDetector(
            onTap: () => widget.onDateChanged(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? widget.selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E(widget.locale).format(date).substring(0, 2),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.d().format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(hasBreakfast, isSelected),
                      _buildIndicator(hasLunch, isSelected),
                      _buildIndicator(hasDinner, isSelected),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
