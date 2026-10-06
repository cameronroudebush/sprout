import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/month_navigation.dart';
import 'package:sprout/shared/widgets/period_picker_dialog.dart';

/// Compact month navigation control with a month-and-year picker.
class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final DateTime? maxMonth;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    this.maxMonth,
  });

  void _changeMonth(int offset, DateTime latestMonth) {
    final nextMonth = MonthNavigation.addMonths(selectedMonth, offset);
    if (!MonthNavigation.isAfter(nextMonth, latestMonth)) {
      onMonthChanged(nextMonth);
    }
  }

  Future<void> _pickMonth(BuildContext context, DateTime latestMonth) async {
    final pickedMonth = await showMonthPickerDialog(
      context: context,
      selectedMonth: selectedMonth,
      maxMonth: latestMonth,
    );

    if (pickedMonth != null) onMonthChanged(pickedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy').format(selectedMonth);
    final latestMonth = MonthNavigation.normalize(maxMonth ?? DateTime.now());
    final canAdvance =
        MonthNavigation.canAdvance(selectedMonth, maxMonth: latestMonth);
    final isCurrentMonth =
        MonthNavigation.isSameMonth(selectedMonth, latestMonth);

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeMonth(-1, latestMonth),
              tooltip: 'Previous month',
            ),
            Expanded(
              child: Center(
                child: TextButton.icon(
                  onPressed: () => _pickMonth(context, latestMonth),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    monthLabel,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      canAdvance ? () => _changeMonth(1, latestMonth) : null,
                  tooltip: 'Next month',
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                  onPressed:
                      isCurrentMonth ? null : () => onMonthChanged(latestMonth),
                  tooltip: 'This month',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
