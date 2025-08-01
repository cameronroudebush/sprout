import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/provider.dart';

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
        final yesterdayNetWorth = netWorthProvider.historicalNetWorth?.getValueByFrame(chartRange).valueChange;
        final percentageChange = yesterdayNetWorth == null
            ? null
            : ((currentNetWorth - yesterdayNetWorth) / yesterdayNetWorth) * 100;
        return Padding(
          padding: EdgeInsetsGeometry.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showNetWorthText) TextWidget(text: "Current Net Worth"),
              TextWidget(
                referenceSize: 2.25,
                text: getFormattedCurrency(currentNetWorth),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(left: 12),
                child: AccountChangeWidget(
                  percentageChange: percentageChange == null || percentageChange.isNaN ? null : percentageChange,
                  totalChange: yesterdayNetWorth,
                  netWorthPeriod: chartRange,
                  mainAxisAlignment: MainAxisAlignment.start,
                  useExtendedPeriodString: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
