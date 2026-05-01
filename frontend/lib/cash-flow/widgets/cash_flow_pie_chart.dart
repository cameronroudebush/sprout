import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';

/// This renders a pie chart for cash flow on how much money came in versus went out
class CashFlowPieChart extends ConsumerWidget {
  final bool showLegend;
  final DateTime selectedDate;
  final double height;
  final CashFlowView view;
  final bool showSubheader;

  const CashFlowPieChart(
    this.selectedDate, {
    super.key,
    this.showLegend = false,
    required this.height,
    this.view = CashFlowView.monthly,
    this.showSubheader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final statsAsync = ref.watch(cashFlowStatsProvider(year: year, month: month));
    final formatter = ref.watch(currencyFormatterProvider);

    return statsAsync.when(
      loading: () => SproutCard(
        child: SizedBox(
          height: height + 50,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => SproutCard(
        height: height + 50,
        child: Center(child: Text("Error loading chart: $err")),
      ),
      data: (stats) {
        final periodText = CashFlowViewFormatter.getPeriodText(view, selectedDate);

        if (stats == null) {
          return SproutCard(
            height: height + 50,
            child: Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate))),
          );
        }

        final totalIncome = stats.totalIncome;
        final totalExpense = stats.totalExpense;

        // Create mapping or handle zero state
        final bool hasData = totalIncome != 0 || totalExpense != 0;
        final Map<String, double>? data =
            hasData ? {"Income": totalIncome.toDouble(), "Expense": totalExpense.abs().toDouble()} : null;

        if (data == null) {
          return SproutCard(
            height: height,
            child: Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate))),
          );
        }

        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: data,
            colorMapping: {"Income": Colors.green, "Expense": theme.colorScheme.error},
            header: "Cash Flow",
            subheader: showSubheader ? periodText : null,
            showLegend: showLegend,
            showPieValue: true,
            formatValue: (value) => formatter.format(value),
            height: height,
          ),
        );
      },
    );
  }
}
