import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';

/// Displays the current net worth value
class CurrentNetWorthDisplay extends StatelessWidget {
  /// If we should clarify what this number is
  final bool showNetWorthText;

  final ChartRange chartRange;
  const CurrentNetWorthDisplay({super.key, required this.chartRange, this.showNetWorthText = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetWorthProvider>(
      builder: (context, netWorthProvider, child) {
        if (netWorthProvider.netWorth == null) {
          return Center(child: CircularProgressIndicator());
        }
        final currentNetWorth = netWorthProvider.netWorth ?? 0;
        final pastValueRange = netWorthProvider.historicalNetWorth?.getValueByFrame(chartRange);
        final pastNetWorthChange = pastValueRange?.valueChange;
        final percentageChange = pastValueRange?.percentChange ?? 0;

        return NetWorthTextWidget(
          chartRange,
          currentNetWorth,
          percentageChange,
          pastNetWorthChange,
          title: "Current Net Worth",
          renderTitle: showNetWorthText,
        );
      },
    );
  }
}
