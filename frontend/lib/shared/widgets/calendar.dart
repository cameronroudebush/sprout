import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/shared/models/extensions/box_decoration_extensions.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// A generic calendar intended to display the given content
class SproutCalendar<T> extends StatefulWidget {
  /// The events to display
  final List<T> events;

  /// A function that allows decoration of specific day cells
  final BoxDecoration? Function(BuildContext context, List<T> events)? cellDecorationBuilder;

  /// On day selected callback
  final void Function(DateTime day, List<T> events)? onDaySelected;

  /// A callback used to determine what we display each day
  final Widget Function(BuildContext context, List<T> events)? dayDisplay;

  /// Function that allows us to parse the date and determine if it is on the given date
  final bool Function(DateTime day, T event) isOnDay;

  /// Whether to display days from the previous/next month that fill the grid.
  final bool displayOutsideDays;

  /// If we should allow changing months, days, etc.
  final bool allowSelection;

  final String? subheader;

  const SproutCalendar(this.events, this.isOnDay,
      {super.key,
      this.onDaySelected,
      this.dayDisplay,
      this.displayOutsideDays = false,
      this.allowSelection = true,
      this.cellDecorationBuilder,
      this.subheader});

  @override
  State<SproutCalendar> createState() => _SproutCalendarState<T>();
}

class _SproutCalendarState<T> extends State<SproutCalendar<T>> {
  DateTime _focusedDate = DateTime.now();

  void _previousMonth() => setState(() => _focusedDate = DateUtils.addMonthsToMonthDate(_focusedDate, -1));
  void _nextMonth() => setState(() => _focusedDate = DateUtils.addMonthsToMonthDate(_focusedDate, 1));

  void _focusDay(DateTime day) {
    final events = widget.events.where((e) => widget.isOnDay(day, e)).toList();
    setState(() => _focusedDate = day);
    if (widget.onDaySelected != null) {
      widget.onDaySelected!(day, events);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var days = _getDaysInMonth(_focusedDate);
    if (!widget.displayOutsideDays) {
      final lastDayOfMonthIndex = days.lastIndexWhere((d) => d.month == _focusedDate.month);
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
            padding: EdgeInsets.only(left: 8, right: 8, bottom: widget.allowSelection ? 0 : 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.allowSelection)
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Tooltip(
                          message: "Go to today's date.",
                          child: IconButton(
                            icon: const Icon(Icons.today),
                            onPressed: !DateUtils.isSameDay(_focusedDate, DateTime.now()) && widget.allowSelection
                                ? () => _focusDay(DateTime.now())
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!widget.allowSelection) const SizedBox.shrink(),
                Expanded(
                  child: SproutChartHeader(
                    title: DateFormat.yMMMM().format(_focusedDate),
                    subheader: widget.subheader,
                  ),
                ),
                if (widget.allowSelection)
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
                if (!widget.allowSelection) const SizedBox.shrink()
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: dayHeaders.map((h) {
                return Expanded(
                  child: Center(
                    child: Text(h, style: theme.textTheme.bodySmall),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendar Grid Layout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: isDesktop ? 1.75 : 1,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final eventsForDay = widget.events.where((e) => widget.isOnDay(date, e)).toList();
                return _CalendarCell(
                  date: date,
                  focusedDate: _focusedDate,
                  events: eventsForDay,
                  displayOutsideDays: widget.displayOutsideDays,
                  eventMarkerBuilder: widget.dayDisplay,
                  cellDecorationBuilder: widget.cellDecorationBuilder,
                  onDaySelected: (day, List<T> events) => _focusDay(day),
                );
              },
            ),
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
  final BoxDecoration? Function(BuildContext context, List<T> events)? cellDecorationBuilder;

  const _CalendarCell({
    super.key,
    required this.date,
    required this.focusedDate,
    required this.events,
    required this.displayOutsideDays,
    required this.eventMarkerBuilder,
    this.cellDecorationBuilder,
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

    final defaultDecoration = BoxDecoration(
        color: isFocused ? theme.colorScheme.primary.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? BoxBorder.all(color: theme.colorScheme.secondary)
            : BoxBorder.all(color: Colors.grey.withValues(alpha: 0.3)));
    final customDecoration = cellDecorationBuilder?.call(context, events);

    return InkWell(
      onTap: () => onDaySelected?.call(date, events),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: defaultDecoration.merge(customDecoration),
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
