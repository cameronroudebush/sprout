import 'package:flutter/material.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/utils/formatters.dart';

/// Displays the net worth value for the given data
class NetWorthTextWidget extends StatelessWidget {
  final String title;
  final bool renderTitle;
  final ChartRangeEnum chartRange;

  final num netWorth;
  final num? percentageChange;
  final num? totalChange;

  final bool applyColor;

  const NetWorthTextWidget(
    this.chartRange,
    this.netWorth,
    this.percentageChange,
    this.totalChange, {
    super.key,
    this.title = "Net Worth",
    this.renderTitle = true,
    this.applyColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsGeometry.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (renderTitle) Text(title, style: TextStyle(fontSize: 16)),
          Text(
            getFormattedCurrency(netWorth),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: applyColor ? getBalanceColor(netWorth, theme) : null,
              fontSize: 30,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 12),
            child: AccountChangeWidget(
              percentageChange: percentageChange == null || percentageChange!.isNaN ? null : percentageChange,
              totalChange: totalChange,
              netWorthPeriod: chartRange,
              mainAxisAlignment: MainAxisAlignment.start,
              useExtendedPeriodString: true,
            ),
          ),
        ],
      ),
    );
  }
}
