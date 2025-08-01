import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/charts/pie_chart.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/transaction/provider.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends StatelessWidget {
  final bool showLegend;
  const CategoryPieChart({super.key, this.showLegend = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final data = provider.transactionStats?.categories;
        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(data: data, header: "Categories", showLegend: showLegend, showPieTitle: false),
        );
      },
    );
  }
}
