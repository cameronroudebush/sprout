import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/model/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';

/// Displays the current net worth value
class CurrentNetWorthDisplay extends StatelessWidget {
  /// If we should clarify what this number is
  final bool showNetWorthText;

  final ChartRangeEnum chartRange;
  const CurrentNetWorthDisplay({super.key, required this.chartRange, this.showNetWorthText = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetWorthProvider>(
      builder: (context, netWorthProvider, child) {
        final totalData = netWorthProvider.total;
        final total = totalData?.value;
        if (total == null) return Center(child: CircularProgressIndicator());

        final currentNetWorth = total;
        final pastValueRange = totalData?.history.getValueByFrame(chartRange);
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
