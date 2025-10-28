import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/widgets/card.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends StatelessWidget {
  final bool showLegend;
  const CategoryPieChart({super.key, this.showLegend = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final data = provider.categoryStats?.categoryCount;
        if (provider.isLoading) {
          return SproutCard(child: Center(child: CircularProgressIndicator()));
        }
        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(data: data, header: "Categories", showLegend: showLegend, showPieTitle: false),
        );
      },
    );
  }
}
