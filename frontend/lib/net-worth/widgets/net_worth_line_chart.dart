import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/net-worth/provider.dart';

/// A line chart that displays the given data in a line chart format
class NetWorthLineChart extends StatelessWidget {
  /// The chart range to render of
  final ChartRange chartRange;

  const NetWorthLineChart({super.key, required this.chartRange});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetWorthProvider>(
      builder: (context, provider, child) {
        final data = provider.historicalNetWorth?.historicalData;
        if (data == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SproutLineChart(data: data, chartRange: chartRange);
        }
      },
    );
  }
}
