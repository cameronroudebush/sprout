import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends StatefulWidget {
  final bool showLegend;
  const CategoryPieChart({super.key, this.showLegend = true});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends AutoUpdateState<CategoryPieChart> {
  /// If we've checked with the user config and already set the default range.
  bool hasSetDefault = false;

  @override
  late Future<dynamic> Function(bool showLoaders) loadData = ServiceLocator.get<CategoryProvider>().loadCategoryStats;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final data = provider.categoryStats?.categoryCount;
        if (provider.isLoading) {
          return SproutCard(
            child: SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
          );
        }
        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(data: data, header: "Categories", showLegend: widget.showLegend, showPieTitle: false),
        );
      },
    );
  }
}
