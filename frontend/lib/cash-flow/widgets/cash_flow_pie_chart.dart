import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/widgets/overview.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';

/// This renders a pie chart for cash flow on how much money came in versus went out
class CashFlowPieChart extends StatefulWidget {
  final bool showLegend;
  final DateTime selectedDate;
  final double? height;
  final CashFlowView view;
  const CashFlowPieChart(
    this.selectedDate, {
    super.key,
    this.showLegend = false,
    this.height,
    this.view = CashFlowView.monthly,
  });

  @override
  State<CashFlowPieChart> createState() => _CashFlowPieChartState();
}

class _CashFlowPieChartState extends AutoUpdateState<CashFlowPieChart> {
  @override
  late Future<dynamic> Function(bool showLoaders) loadData = (showLoaders) async {
    final date = widget.selectedDate;
    final provider = ServiceLocator.get<CashFlowProvider>();
    final month = widget.view == CashFlowView.monthly ? date.month : null;
    provider.setLoadingStatus(true);
    if (provider.getStatsData(date.year, month) == null) {
      context.read<CashFlowProvider>().getStats(date.year, month);
    }
    provider.setLoadingStatus(false);
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<CashFlowProvider>(
      builder: (context, provider, child) {
        final month = widget.view == CashFlowView.monthly ? widget.selectedDate.month : null;
        final stats = provider.getStatsData(widget.selectedDate.year, month);
        if (stats == null || provider.isLoading) {
          return SproutCard(
            child: SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
          );
        }

        final totalIncome = stats.totalIncome;
        final totalExpense = stats.totalExpense;
        // Create our mapping
        final data = totalIncome == 0 || totalExpense == 0
            ? null
            : {"Income": totalIncome, "Spent": totalExpense.abs()};

        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: data,
            colorMapping: {"Income": Colors.green, "Spent": Colors.red[700]!},
            header: "Cash Flow",
            showLegend: widget.showLegend,
            showPieValue: true,
            formatValue: (value) => getFormattedCurrency(value),
            height: widget.height ?? 250,
          ),
        );
      },
    );
  }
}
