import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';

/// A generic calendar intended to display the given content
class SproutCalendar<T> extends StatefulWidget {
  /// The events to display
  final List<T> events;

  /// On day selected callback
  final void Function(DateTime day, List<T> events)? onDaySelected;

  /// A callback used to determine what we display each day
  final Widget Function(BuildContext context, List<T> events)? dayDisplay;

  /// Function that allows us to parse the date and determine if it is on the given date
  final bool Function(DateTime day, T event) isOnDay;

  /// Whether to display days from the previous/next month that fill the grid.
  final bool displayOutsideDays;

  const SproutCalendar(
    this.events,
    this.isOnDay, {
    super.key,
    this.onDaySelected,
    this.dayDisplay,
    this.displayOutsideDays = false,
  });

  @override
  State<SproutCalendar> createState() => _SproutCalendarState<T>();
}

class _SproutCalendarState<T> extends State<SproutCalendar<T>> {
  // The month and year currently being displayed on the calendar.
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Delay this execution by 1 millisecond
    Timer(const Duration(milliseconds: 1), () {
      final date = DateTime.now();
      // Find events for the specific day from our grouped map.
      final eventsForDay = widget.events.where((e) {
        return widget.isOnDay(date, e);
      }).toList();
      if (widget.onDaySelected != null) {
        widget.onDaySelected!(date, eventsForDay);
      }
    });
  }

  /// Moves the calendar to the previous month.
  void _previousMonth() {
    setState(() {
      _focusedDate = DateUtils.addMonthsToMonthDate(_focusedDate, -1);
    });
  }

  /// Moves the calendar to the next month.
  void _nextMonth() {
    setState(() {
      _focusedDate = DateUtils.addMonthsToMonthDate(_focusedDate, 1);
    });
  }

  void _focusDay(DateTime day) {
    final events = widget.events.where((e) {
      return widget.isOnDay(day, e);
    }).toList();
    setState(() {
      _focusedDate = day;
    });
    if (widget.onDaySelected != null) {
      widget.onDaySelected!(day, events);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var days = _getDaysInMonth(_focusedDate);
    if (!widget.displayOutsideDays) {
      // Find the index of the last day that actually belongs to the current month
      final lastDayOfMonthIndex = days.lastIndexWhere((d) => d.month == _focusedDate.month);
      // Calculate how many weeks (rows) are needed to include that day.
      final weeksNeeded = (lastDayOfMonthIndex ~/ 7) + 1;
      days = days.take(weeksNeeded * 7).toList();
    }

    final dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month/Year - Navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      SproutTooltip(
                        message: "Go to today's date.",
                        child: IconButton(
                          icon: const Icon(Icons.today),
                          onPressed: !DateUtils.isSameDay(_focusedDate, DateTime.now())
                              ? () => _focusDay(DateTime.now())
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat.yMMMM().format(_focusedDate),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                        onPressed: _previousMonth,
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Day of Week Headers
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: TextWidget(
                  text: dayHeaders[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          // Calendar Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: isDesktop ? 2.5 : 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              // Find events for the specific day from our grouped map.
              final eventsForDay = widget.events.where((e) {
                return widget.isOnDay(date, e);
              }).toList();

              return _CalendarCell(
                date: date,
                focusedDate: _focusedDate,
                events: eventsForDay,
                displayOutsideDays: widget.displayOutsideDays,
                eventMarkerBuilder: widget.dayDisplay,
                onDaySelected: (day, List<T> events) {
                  _focusDay(day);
                },
              );
            },
          ),
        ],
      );
    });
  }

  /// Calculates the list of days to display for a given month,
  /// including days from the previous and next months to fill the grid.
  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final startOfCalendar = DateUtils.addDaysToDate(firstDayOfMonth, -firstWeekday);
    return List.generate(42, (index) => DateUtils.addDaysToDate(startOfCalendar, index));
  }
}

/// A widget representing a single cell in the calendar grid.
class _CalendarCell<T> extends StatelessWidget {
  final DateTime date;
  final DateTime focusedDate;
  final List<T> events;
  final bool displayOutsideDays;
  final Widget Function(BuildContext context, List<T> events)? eventMarkerBuilder;
  final void Function(DateTime day, List<T> events)? onDaySelected;

  const _CalendarCell({
    super.key,
    required this.date,
    required this.focusedDate,
    required this.events,
    required this.displayOutsideDays,
    required this.eventMarkerBuilder,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday =
        date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
    final isThisMonth = date.month == focusedDate.month;
    final isFocused = date.day == focusedDate.day && date.month == focusedDate.month && date.year == focusedDate.year;

    // Hide the day if it's not in the current month and the flag is off
    if (!displayOutsideDays && !isThisMonth) return Container();

    return InkWell(
      onTap: () => onDaySelected?.call(date, events),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isFocused ? theme.colorScheme.primary.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? BoxBorder.all(color: theme.colorScheme.secondary) : null,
        ),
        child: Column(
          children: [
            //  Day Number
            Text('${date.day}', style: !isThisMonth ? const TextStyle(color: Colors.grey) : null),
            // Event Marker
            if (eventMarkerBuilder != null) Expanded(child: eventMarkerBuilder!(context, events)),
          ],
        ),
      ),
    );
  }
}
