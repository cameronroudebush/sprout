import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/net-worth/model/historical_data_point_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';

class NetWorthLineChart extends StatefulWidget {
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
  State<NetWorthLineChart> createState() => _NetWorthLineChartState();
}

/// A line chart that displays the given data in a line chart format
class _NetWorthLineChartState extends StateTracker<NetWorthLineChart> with SproutProviders {
  @override
  Map<dynamic, DataRequest> get requests => {};

  @override
  Widget build(BuildContext context) {
    return Consumer<NetWorthProvider>(
      builder: (context, provider, child) {
        final data = netWorthProvider.total;
        if (data == null) {
          return Center(
            child: Text("No data found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          );
        } else {
          return SproutLineChart(
            data: HistoricalDataPointExtensions.toMap(data.timeline),
            chartRange: widget.chartRange,
            formatValue: (value) => getFormattedCurrency(value),
            showYAxis: widget.showYAxis,
            showXAxis: widget.showXAxis,
            formatYAxis: (value) => getShortFormattedCurrency(value),
            height: widget.height ?? 200,
            showGrid: true,
          );
        }
      },
    );
  }
}
