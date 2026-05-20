import 'package:collection/collection.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends ConsumerWidget {
  final PieLegendPosition legendPosition;
  final double height;
  final DateTime selectedDate;
  final CashFlowView view;
  final bool showSubheader;

  /// Number of top categories to show
  final int? topN;

  const CategoryPieChart(
    this.selectedDate, {
    super.key,
    required this.legendPosition,
    required this.height,
    this.view = CashFlowView.monthly,
    this.showSubheader = true,
    this.topN,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final statsAsync = ref.watch(categoryStatsProvider(year: year, month: month));

    return statsAsync.when(
      loading: () => SproutCard(
        child: SizedBox(
          height: height + 50,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => SproutCard(
        height: height + 65,
        child: Center(child: Text("Error loading category stats")),
      ),
      data: (data) {
        final rawData = data?.categoryCount;
        if (rawData == null || rawData.isEmpty) {
          return SproutCard(
              height: height, child: Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate))));
        }

        final filteredEntries = rawData.entries.where((e) => e.value > 0).toList();
        final sortedEntries = filteredEntries.sortedBy((e) => e.value).reversed.toList();
        final colorMapping = data!.colorMapping.map((a, b) => MapEntry(a, b.toColor));

        Map<String, num> finalData = {};

        if (topN != null && sortedEntries.length > topN!) {
          final top = sortedEntries.take(topN!);
          final others = sortedEntries.skip(topN!);

          final otherSum = others.fold(0.0, (prev, e) => prev + e.value);

          finalData = Map.fromEntries(top);
          if (otherSum > 0) {
            finalData["+${others.length} more categories"] = otherSum;
            colorMapping["+${others.length} more categories"] = Colors.grey;
          }
        } else {
          finalData = Map.fromEntries(sortedEntries);
        }

        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: finalData,
            colorMapping: colorMapping,
            header: "Categories",
            subheader: showSubheader ? CashFlowViewFormatter.getPeriodText(view, selectedDate) : null,
            legendPosition: legendPosition,
            showPieTitle: false,
            height: height,
          ),
        );
      },
    );
  }
}
