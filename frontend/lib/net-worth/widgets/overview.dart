import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/net-worth/widgets/current_net_worth.dart';
import 'package:sprout/net-worth/widgets/net_worth_line_chart.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';

/// Displays the current net worth in a pretty overview
class NetWorthOverviewWidget extends StatelessWidget {
  /// If we should render this within a card
  final bool showCard;

  /// The current range of data we wish to display
  final ChartRange selectedChartRange;

  /// Whenever we have a new range selected, this will be fired
  final ValueChanged<ChartRange>? onRangeSelected;

  /// If we should clarify what this number is
  final bool showNetWorthText;

  const NetWorthOverviewWidget({
    super.key,
    this.showCard = false,
    required this.selectedChartRange,
    this.onRangeSelected,
    this.showNetWorthText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetWorthProvider>(
      builder: (context, netWorthProvider, child) {
        // Build our content to render
        final content = Padding(
          padding: const EdgeInsets.only(top: 12, right: 12, left: 12),
          child: netWorthProvider.isLoading || netWorthProvider.netWorth == null
              ? const SizedBox(height: 325, child: Center(child: CircularProgressIndicator()))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurrentNetWorthDisplay(chartRange: selectedChartRange, showNetWorthText: showNetWorthText),
                    NetWorthLineChart(chartRange: selectedChartRange),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: ChartRangeSelector(
                        selectedChartRange: selectedChartRange,
                        onRangeSelected: onRangeSelected,
                      ),
                    ),
                  ],
                ),
        );

        // Determine if we want to show ths in a card or not
        if (showCard) {
          return Center(child: SproutCard(child: content));
        } else {
          return Center(child: content);
        }
      },
    );
  }
}
