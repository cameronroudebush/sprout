import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/month_navigation.dart';
import 'package:sprout/shared/widgets/period_picker_dialog.dart';
import 'package:sprout/shared/widgets/tab_selector.dart';

/// A widget for selecting the view (monthly/yearly), year, and navigating months for cash flow.
class CashFlowSelector extends StatelessWidget {
  final CashFlowView currentView;
  final DateTime selectedDate;
  final ValueChanged<CashFlowView> onViewChanged;
  final ValueChanged<int> onMonthIncrementChanged;
  final ValueChanged<int> onYearChanged;

  const CashFlowSelector({
    super.key,
    required this.currentView,
    required this.selectedDate,
    required this.onViewChanged,
    required this.onMonthIncrementChanged,
    required this.onYearChanged,
  });

  Future<void> _pickMonth(BuildContext context) async {
    final selectedMonth = MonthNavigation.normalize(selectedDate);
    final pickedMonth = await showMonthPickerDialog(
      context: context,
      selectedMonth: selectedMonth,
      maxMonth: MonthNavigation.currentMonth(),
    );
    if (pickedMonth != null) {
      onMonthIncrementChanged(
          MonthNavigation.differenceInMonths(selectedMonth, pickedMonth));
    }
  }

  Future<void> _pickYear(BuildContext context) async {
    final pickedYear = await showYearPickerDialog(
      context: context,
      selectedYear: selectedDate.year,
    );
    if (pickedYear != null && pickedYear != selectedDate.year) {
      onYearChanged(pickedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final theme = Theme.of(context);
      final now = DateTime.now();
      final currentMonth = MonthNavigation.currentMonth(now: now);
      final isMonthly = currentView == CashFlowView.monthly;
      final previousButton = Tooltip(
        message: isMonthly ? "Previous Month" : "Previous Year",
        child: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => isMonthly
              ? onMonthIncrementChanged(-1)
              : onYearChanged(selectedDate.year - 1),
        ),
      );
      final nextButton = Tooltip(
        message: isMonthly ? "Next Month" : "Next Year",
        child: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: isMonthly
              ? (MonthNavigation.canAdvance(selectedDate,
                      maxMonth: currentMonth)
                  ? () => onMonthIncrementChanged(1)
                  : null)
              : (selectedDate.year < now.year
                  ? () => onYearChanged(selectedDate.year + 1)
                  : null),
        ),
      );
      final currentPeriodButton = Tooltip(
        message: isMonthly ? "This Month" : "This Year",
        child: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_right),
          onPressed: isMonthly
              ? (!MonthNavigation.isSameMonth(selectedDate, currentMonth)
                  ? () => onMonthIncrementChanged(
                      MonthNavigation.differenceInMonths(
                          selectedDate, currentMonth))
                  : null)
              : (selectedDate.year != now.year
                  ? () => onYearChanged(now.year)
                  : null),
        ),
      );
      final periodTabs = SproutTabSelector<CashFlowView>(
        options: const [
          SproutTabOption(value: CashFlowView.monthly, label: 'Monthly'),
          SproutTabOption(value: CashFlowView.yearly, label: 'Yearly'),
        ],
        selected: currentView,
        onSelected: onViewChanged,
        compact: !isDesktop,
      );
      final periodPicker = TextButton.icon(
        onPressed: () => isMonthly ? _pickMonth(context) : _pickYear(context),
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(
          isMonthly
              ? DateFormat(isDesktop ? 'MMMM yyyy' : 'MMM yy')
                  .format(selectedDate)
              : selectedDate.year.toString(),
          style: theme.textTheme.titleMedium,
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 4),
        ),
      );

      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: isDesktop ? 8 : 2,
              children: [periodTabs, periodPicker],
            ),
            // Left side control
            Positioned(
              left: 0,
              child: Center(child: previousButton),
            ),
            // Right side controls
            Positioned(
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [nextButton, currentPeriodButton],
              ),
            ),
          ],
        ),
      );
    });
  }
}
