import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/cash-flow/widgets/overview.dart';
import 'package:sprout/core/widgets/tooltip.dart';

import '../../core/widgets/layout.dart';

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

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final now = DateTime.now();
      final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
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
                  SproutTooltip(
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
                spacing: 16,
                children: [
                  ToggleButtons(
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
                    Text(
                      isDesktop
                          ? DateFormat('MMMM yyyy').format(selectedDate)
                          : DateFormat('MMM yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (currentView == CashFlowView.yearly)
                    Text(
                      selectedDate.year.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            // Next button
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SproutTooltip(
                    message: isMonthly ? "Next Month" : "Next Year",
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: isMonthly
                          ? (selectedDate.isBefore(currentMonthEnd) ? () => onMonthIncrementChanged(1) : null)
                          : (selectedDate.year < now.year ? () => onYearChanged(selectedDate.year + 1) : null),
                    ),
                  ),
                  SproutTooltip(
                    message: isMonthly ? "This Month" : "This Year",
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_right),
                      onPressed: isMonthly
                          ? (selectedDate.month != currentMonthEnd.month || selectedDate.year != currentMonthEnd.year
                                ? () => onMonthIncrementChanged(currentMonthEnd.month - selectedDate.month)
                                : null)
                          : (selectedDate.year != now.year ? () => onYearChanged(now.year) : null),
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
