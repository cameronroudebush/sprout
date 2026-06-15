import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// This renders a pie chart for cash flow on how much money came in versus went out
class CashFlowPieChart extends ConsumerWidget {
  final SproutChartLegendPosition legendPosition;
  final DateTime selectedDate;
  final CashFlowView view;
  final bool showSubheader;
  final SproutChartHeader? header;

  const CashFlowPieChart(this.selectedDate,
      {super.key,
      required this.legendPosition,
      this.view = CashFlowView.monthly,
      this.showSubheader = true,
      this.header});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final statsAsync = ref.watch(cashFlowStatsProvider(year: year, month: month));
    final formatter = ref.watch(currencyFormatterProvider);

    return statsAsync.whenDefault(
      emptyWidget: Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate))),
      data: (stats) {
        final totalIncome = stats!.totalIncome;
        final totalExpense = stats.totalExpense;

        // Create mapping or handle zero state
        final bool hasData = totalIncome != 0 || totalExpense != 0;
        final Map<String, double>? data =
            hasData ? {"Income": totalIncome.toDouble(), "Expense": totalExpense.abs().toDouble()} : null;

        if (data == null) {
          return Center(
            child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate)),
          );
        }

        return SproutPieChart(
          data: data,
          colorMapping: {"Income": Colors.green, "Expense": theme.colorScheme.error},
          header: header,
          legendPosition: legendPosition,
          showPieValue: true,
          formatValue: (value) => formatter.format(value),
        );
      },
    );
  }
}
