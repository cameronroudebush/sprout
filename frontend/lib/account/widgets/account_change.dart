import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';

/// A widget used to display the percentage change of an account with icons and coloring
class AccountChangeWidget extends StatelessWidget {
  final num? percentageChange;
  final num? totalChange;
  final MainAxisAlignment mainAxisAlignment;
  final ChartRangeEnum? netWorthPeriod;
  final bool showPercentage;

  /// If we should use the extended period information for the string (1 month vs 1m)
  final bool useExtendedPeriodString;

  const AccountChangeWidget({
    super.key,
    required this.totalChange,
    this.netWorthPeriod,
    this.percentageChange,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.showPercentage = true,
    this.useExtendedPeriodString = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (percentageChange != null && totalChange != null) {
      final changeColor = getBalanceColor(totalChange!, theme);
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Icon(getChangeIcon(percentageChange!), color: changeColor, size: 16),
          SizedBox(width: 4),
          Row(
            spacing: 4,
            children: [
              TextWidget(
                text: getFormattedCurrency(totalChange ?? 0),
                style: TextStyle(color: changeColor),
              ),
              if (showPercentage)
                TextWidget(
                  referenceSize: .85,
                  text: percentageChange == double.infinity
                      ? "(∞)"
                      : percentageChange!.isNaN
                      ? ""
                      : "(${formatPercentage(percentageChange!)})",
                  style: TextStyle(color: changeColor),
                ),
              if (netWorthPeriod != null)
                TextWidget(
                  referenceSize: .75,
                  text: ChartRangeUtility.asPretty(netWorthPeriod!, useExtendedPeriodString: useExtendedPeriodString),
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
