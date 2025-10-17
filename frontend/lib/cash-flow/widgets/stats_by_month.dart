import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_stats.dart';
import 'package:sprout/cash-flow/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';

/// Renders the stats information with month consideration integrated so it can customize how it displays
class StatsByMonth extends StatelessWidget {
  final DateTime selectedDate;

  const StatsByMonth(this.selectedDate, {super.key});

  /// Returns stats data if available based on the current requirements
  CashFlowStats? _getStatsData() {
    final provider = ServiceLocator.get<CashFlowProvider>();
    return provider.getStatsData(selectedDate.year, selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CashFlowProvider>(
      builder: (context, provider, child) {
        final stats = _getStatsData();
        final income = stats?.totalIncome;
        final expense = stats?.totalExpense;

        if (provider.isLoading || stats == null) {
          return const Center(
            child: Padding(padding: EdgeInsetsGeometry.all(12), child: CircularProgressIndicator()),
          );
        }

        return Padding(
          padding: EdgeInsetsGeometry.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  TextWidget(
                    text: "Total Income",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextWidget(
                    text: income != null ? getFormattedCurrency(income) : 'N/A',
                    style: TextStyle(color: income != null ? getBalanceColor(income, theme) : null),
                  ),
                ],
              ),
              Column(
                children: [
                  TextWidget(
                    text: "Total Expense",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextWidget(
                    text: expense != null ? getFormattedCurrency(expense) : 'N/A',
                    style: TextStyle(color: expense != null ? getBalanceColor(expense, theme) : null),
                  ),
                ],
              ),
              Column(
                children: [
                  TextWidget(
                    text: "Net Flow",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextWidget(
                    text: (income != null && expense != null) ? getFormattedCurrency(income + expense) : 'N/A',
                    style: TextStyle(
                      color: income != null && expense != null ? getBalanceColor(income + expense, theme) : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
