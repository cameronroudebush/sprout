import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/net-worth/model/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';

/// A line chart that displays the given data in a line chart format
class NetWorthLineChart extends StatelessWidget {
  /// The chart range to render of
  final ChartRangeEnum chartRange;

  /// If the y axis number should be shown
  final bool showYAxis;

  /// If the x axis dates should be shown
  final bool showXAxis;

  /// A height to apply to the line chart
  final double? height;

  const NetWorthLineChart({
    super.key,
    required this.chartRange,
    this.showYAxis = false,
    this.showXAxis = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetWorthProvider>(
      builder: (context, provider, child) {
        final data = provider.historicalNetWorth?.historicalDataDate;
        if (!provider.isInitialized) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SproutLineChart(
            data: data,
            chartRange: chartRange,
            formatValue: (value) => getFormattedCurrency(value),
            showYAxis: showYAxis,
            showXAxis: showXAxis,
            formatYAxis: (value) => getShortFormattedCurrency(value),
            height: height ?? 250,
            showGrid: true,
          );
        }
      },
    );
  }
}
