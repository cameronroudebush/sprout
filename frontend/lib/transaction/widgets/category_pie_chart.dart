import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/state_tracker.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends StatefulWidget {
  final bool showLegend;
  final double height;
  final DateTime selectedDate;
  final CashFlowView view;
  final bool showSubheader;

  const CategoryPieChart(
    this.selectedDate, {
    super.key,
    this.showLegend = true,
    required this.height,
    this.view = CashFlowView.monthly,
    this.showSubheader = true,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends StateTracker<CategoryPieChart> {
  /// If we've checked with the user config and already set the default range.
  bool hasSetDefault = false;

  @override
  Map<dynamic, DataRequest> get requests {
    final date = widget.selectedDate;
    final month = widget.view == CashFlowView.monthly ? date.month : null;
    final provider = context.read<CategoryProvider>();

    return {
      'stats': DataRequest<CategoryProvider, dynamic>(
        provider: provider,
        onLoad: (p, force) => p.loadCategoryStats(date.year, month),
        getFromProvider: (p) => p.getStatsData(date.year, month),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (isLoading) {
          return SproutCard(
            child: SizedBox(
              height: widget.height + 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final month = widget.view == CashFlowView.monthly ? widget.selectedDate.month : null;
        final data = provider.getStatsData(widget.selectedDate.year, month);
        final categoryCount = data?.categoryCount;

        if (categoryCount == null || categoryCount.isEmpty) {
          return SproutCard(
            height: widget.height,
            child: Center(child: Text(CashFlowViewFormatter.getNoDataText(widget.view, widget.selectedDate))),
          );
        }
        final periodText = CashFlowViewFormatter.getPeriodText(widget.view, widget.selectedDate);

        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: categoryCount,
            colorMapping: data!.colorMapping.map((a, b) => MapEntry(a, b.toColor)),
            header: "Categories",
            subheader: widget.showSubheader ? periodText : null,
            showLegend: widget.showLegend,
            showPieTitle: false,
            height: widget.height,
            onSliceTap: (slice, val) {
              SproutNavigator.redirectToCatFilter(slice);
            },
          ),
        );
      },
    );
  }
}
