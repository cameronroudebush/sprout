import 'package:flutter/material.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';

/// Displays the net worth value for the given data
class NetWorthTextWidget extends StatelessWidget {
  final String title;
  final bool renderTitle;
  final ChartRange chartRange;

  final double netWorth;
  final double? percentageChange;
  final double? totalChange;

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
          if (renderTitle) TextWidget(text: title),
          TextWidget(
            referenceSize: 2.25,
            text: getFormattedCurrency(netWorth),
            style: TextStyle(fontWeight: FontWeight.bold, color: applyColor ? getBalanceColor(netWorth, theme) : null),
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
