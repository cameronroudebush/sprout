import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/transaction/provider.dart';

/// This renders a pie chart for cash flow information
class CashFlowPieChart extends StatelessWidget {
  final bool showLegend;
  const CashFlowPieChart({super.key, this.showLegend = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final totalIncome = provider.transactionStats?.totalIncome;
        final totalSpent = provider.transactionStats?.totalSpend;
        // Create our mapping
        final data = totalIncome == null || totalIncome == 0 || totalSpent == null || totalSpent == 0
            ? null
            : {"Income": totalIncome, "Spent": totalSpent.abs()};
        if (provider.isLoading) {
          return SproutCard(child: Center(child: CircularProgressIndicator()));
        }
        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: data,
            colorMapping: {"Income": Colors.green, "Spent": Colors.red[700]!},
            header: "Cash Flow",
            showLegend: showLegend,
            formatValue: (value) => getFormattedCurrency(value),
          ),
        );
      },
    );
  }
}
