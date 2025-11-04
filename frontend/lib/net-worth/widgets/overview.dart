import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/current_net_worth.dart';
import 'package:sprout/net-worth/widgets/net_worth_line_chart.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';

/// Displays the current net worth in a pretty overview
class NetWorthOverviewWidget extends StatefulWidget {
  /// If we should render this within a card
  final bool showCard;

  /// The current range of data we wish to display
  final ChartRangeEnum selectedChartRange;

  /// Whenever we have a new range selected, this will be fired
  final ValueChanged<ChartRangeEnum>? onRangeSelected;

  /// If we should clarify what this number is
  final bool showNetWorthText;

  final double chartHeight;

  const NetWorthOverviewWidget({
    super.key,
    this.showCard = false,
    required this.selectedChartRange,
    this.onRangeSelected,
    this.showNetWorthText = true,
    this.chartHeight = 250,
  });

  @override
  State<NetWorthOverviewWidget> createState() => _NetWorthOverviewWidgetState();
}

class _NetWorthOverviewWidgetState extends AutoUpdateState<NetWorthOverviewWidget, NetWorthProvider> {
  @override
  NetWorthProvider provider = ServiceLocator.get<NetWorthProvider>();
  @override
  Future<dynamic> Function(bool showLoaders) loadData = ServiceLocator.get<NetWorthProvider>().loadHomePageData;

  @override
  Widget build(BuildContext context) {
    return Consumer<NetWorthProvider>(
      builder: (context, netWorthProvider, child) {
        final selectedChartRange = widget.selectedChartRange;

        // Build our content to render
        final content = Padding(
          padding: const EdgeInsets.only(top: 12, right: 12, left: 12),
          child:
              // Data is loading
              netWorthProvider.isLoading
              ? SizedBox(
                  height: widget.chartHeight + 75,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurrentNetWorthDisplay(chartRange: selectedChartRange, showNetWorthText: widget.showNetWorthText),
                    NetWorthLineChart(chartRange: selectedChartRange, height: widget.chartHeight),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: ChartRangeSelector(
                        selectedChartRange: selectedChartRange,
                        onRangeSelected: widget.onRangeSelected,
                      ),
                    ),
                  ],
                ),
        );

        // Determine if we want to show ths in a card or not
        if (widget.showCard) {
          return Center(child: SproutCard(child: content));
        } else {
          return Center(child: content);
        }
      },
    );
  }
}
