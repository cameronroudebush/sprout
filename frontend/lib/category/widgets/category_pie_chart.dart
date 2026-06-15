import 'package:collection/collection.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends ConsumerWidget {
  final SproutChartLegendPosition legendPosition;
  final DateTime selectedDate;
  final CashFlowView view;
  final SproutChartHeader? header;

  /// Number of top categories to show
  final int? topN;

  const CategoryPieChart(this.selectedDate,
      {super.key, required this.legendPosition, this.view = CashFlowView.monthly, this.topN, this.header});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final statsAsync = ref.watch(categoryStatsProvider(year: year, month: month));

    return statsAsync.whenDefault(
      emptyCondition: (data) => data == null || data.categoryCount.isEmpty,
      emptyWidget: Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate))),
      data: (data) {
        final rawData = data!.categoryCount;
        final filteredEntries = rawData.entries.where((e) => e.value > 0).toList();
        final sortedEntries = filteredEntries.sortedBy((e) => e.value).reversed.toList();
        final colorMapping = data.colorMapping.map((a, b) => MapEntry(a, b.toColor));

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

        return SproutPieChart(
          data: finalData,
          colorMapping: colorMapping,
          legendPosition: legendPosition,
          showPieTitle: false,
          header: header,
        );
      },
    );
  }
}
