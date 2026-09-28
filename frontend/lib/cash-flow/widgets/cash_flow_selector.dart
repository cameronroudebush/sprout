import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/month_navigation.dart';
import 'package:sprout/shared/widgets/period_picker_dialog.dart';

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

      return Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back button
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: isMonthly ? "Previous Month" : "Previous Year",
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => isMonthly ? onMonthIncrementChanged(-1) : onYearChanged(selectedDate.year - 1),
                    ),
                  ),
                ],
              ),
            ),
            // Current value display
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  ToggleButtons(
                    constraints: const BoxConstraints(
                      minHeight: 28.0,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Disables material margin padding
                    isSelected: [currentView == CashFlowView.monthly, currentView == CashFlowView.yearly],
                    onPressed: (index) {
                      onViewChanged(index == 0 ? CashFlowView.monthly : CashFlowView.yearly);
                    },
                    children: const [
                      Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 6), child: Text('Monthly')),
                      Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 6), child: Text('Yearly')),
                    ],
                  ),
                  if (currentView == CashFlowView.monthly) ...[
                    TextButton.icon(
                      onPressed: () => _pickMonth(context),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        isDesktop
                            ? DateFormat('MMMM yyyy').format(selectedDate)
                            : DateFormat('MMM yyyy').format(selectedDate),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                  if (currentView == CashFlowView.yearly)
                    TextButton.icon(
                      onPressed: () => _pickYear(context),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        selectedDate.year.toString(),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                ],
              ),
            ),
            // Next button
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
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
                  ),
                  Tooltip(
                    message: isMonthly ? "This Month" : "This Year",
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_right),
                      onPressed: isMonthly
                          ? (!MonthNavigation.isSameMonth(
                                  selectedDate, currentMonth)
                              ? () => onMonthIncrementChanged(
                                  MonthNavigation.differenceInMonths(
                                      selectedDate, currentMonth))
                              : null)
                          : (selectedDate.year != now.year
                              ? () => onYearChanged(now.year)
                              : null),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
