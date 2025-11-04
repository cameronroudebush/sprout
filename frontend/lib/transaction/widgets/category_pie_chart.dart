import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends StatefulWidget {
  final bool showLegend;
  final double height;
  final DateTime selectedDate;
  final CashFlowView view;
  const CategoryPieChart(
    this.selectedDate, {
    super.key,
    this.showLegend = true,
    required this.height,
    this.view = CashFlowView.monthly,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends AutoUpdateState<CategoryPieChart, CategoryProvider> {
  /// If we've checked with the user config and already set the default range.
  bool hasSetDefault = false;

  /// Fetches data we need for the display of the given selected date.
  ///   We use [showLoaders] as a way to forcibly say we need updated data.
  Future<void> _fetchData(bool showLoaders) async {
    final provider = ServiceLocator.get<CategoryProvider>();
    final selectedDate = widget.selectedDate;
    final month = widget.view == CashFlowView.monthly ? selectedDate.month : null;
    provider.setLoadingStatus(true);
    if (showLoaders || provider.getStatsData(selectedDate.year, month) == null) {
      provider.loadCategoryStats(selectedDate.year, month);
    }
    provider.setLoadingStatus(false);
  }

  @override
  CategoryProvider provider = ServiceLocator.get<CategoryProvider>();
  @override
  late Future<dynamic> Function(bool showLoaders) loadData = _fetchData;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (isLoading) {
          return SproutCard(
            child: SizedBox(
              height: widget.height,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final month = widget.view == CashFlowView.monthly ? widget.selectedDate.month : null;
        final data = provider.getStatsData(widget.selectedDate.year, month)?.categoryCount;

        if (data == null || data.isEmpty) {
          return SproutCard(
            height: widget.height,
            child: Center(child: Text(CashFlowViewFormatter.getNoDataText(widget.view, widget.selectedDate))),
          );
        }

        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: data,
            header: "Categories",
            showLegend: widget.showLegend,
            showPieTitle: false,
            height: widget.height,
          ),
        );
      },
    );
  }
}
