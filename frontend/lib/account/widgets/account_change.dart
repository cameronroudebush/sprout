import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';

/// A widget used to display the percentage change of an account with icons and coloring
class AccountChangeWidget extends StatelessWidget {
  final double? percentageChange;
  final double totalChange;
  final MainAxisAlignment mainAxisAlignment;
  final String? netWorthPeriod;
  final bool showPercentage;

  const AccountChangeWidget({
    super.key,
    required this.totalChange,
    this.netWorthPeriod,
    this.percentageChange,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.showPercentage = true,
  });

  String _netWorthPeriodAsPretty() {
    switch (netWorthPeriod) {
      case "last1Day":
        return "1 day";
      case "last7Days":
        return "1 week";
      case "last30Days":
        return "1 month";
      case "lastYear":
        return "1 year";
      default:
        return netWorthPeriod!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (percentageChange != null) {
      final changeColor = getBalanceColor(percentageChange!, theme);
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Icon(getChangeIcon(percentageChange!), color: changeColor, size: 16),
          SizedBox(width: 4),
          Row(
            spacing: 4,
            children: [
              TextWidget(
                text: currencyFormatter.format(totalChange),
                style: TextStyle(color: changeColor),
              ),
              if (showPercentage)
                TextWidget(
                  referenceSize: .85,
                  text: "(${formatPercentage(percentageChange!)})",
                  style: TextStyle(color: changeColor),
                ),
              if (netWorthPeriod != null)
                TextWidget(
                  referenceSize: .75,
                  text: _netWorthPeriodAsPretty(),
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
