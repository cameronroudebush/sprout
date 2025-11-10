import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';

/// This renders a pie chart for cash flow on how much money came in versus went out
class CashFlowPieChart extends StatefulWidget {
  final bool showLegend;
  final DateTime selectedDate;
  final double height;
  final CashFlowView view;

  const CashFlowPieChart(
    this.selectedDate, {
    super.key,
    this.showLegend = false,
    required this.height,
    this.view = CashFlowView.monthly,
  });

  @override
  State<CashFlowPieChart> createState() => _CashFlowPieChartState();
}

class _CashFlowPieChartState extends AutoUpdateState<CashFlowPieChart, CashFlowProvider> {
  /// Fetches data we need for the display of the given selected date.
  ///   We use [showLoaders] as a way to forcibly say we need updated data.
  Future<void> _fetchData(bool showLoaders) async {
    final date = widget.selectedDate;
    final month = widget.view == CashFlowView.monthly ? date.month : null;
    provider.setLoadingStatus(true);
    if (showLoaders || provider.getStatsData(date.year, month) == null) {
      await context.read<CashFlowProvider>().getStats(date.year, month);
    }
    provider.setLoadingStatus(false);
  }

  @override
  CashFlowProvider provider = ServiceLocator.get<CashFlowProvider>();

  @override
  late Future<dynamic> Function(bool showLoaders) loadData = _fetchData;

  @override
  Widget build(BuildContext context) {
    return Consumer<CashFlowProvider>(
      builder: (context, provider, child) {
        final month = widget.view == CashFlowView.monthly ? widget.selectedDate.month : null;
        final stats = provider.getStatsData(widget.selectedDate.year, month);
        if (isLoading) {
          return SproutCard(
            child: SizedBox(
              height: widget.height + 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (stats == null) {
          return SproutCard(
            height: widget.height + 50,
            child: Center(child: Text(CashFlowViewFormatter.getNoDataText(widget.view, widget.selectedDate))),
          );
        }

        final totalIncome = stats.totalIncome;
        final totalExpense = stats.totalExpense;
        // Create our mapping
        final data = totalIncome == 0 || totalExpense == 0
            ? null
            : {"Income": totalIncome, "Spent": totalExpense.abs()};

        if (data == null) {
          return SproutCard(
            height: widget.height,
            child: Center(child: Text(CashFlowViewFormatter.getNoDataText(widget.view, widget.selectedDate))),
          );
        }

        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: data,
            colorMapping: {"Income": Colors.green, "Spent": Colors.red[700]!},
            header: "Cash Flow",
            showLegend: widget.showLegend,
            showPieValue: true,
            formatValue: (value) => getFormattedCurrency(value),
            height: widget.height,
          ),
        );
      },
    );
  }
}
