import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';

/// A widget used to display the percentage change of an account with icons and coloring
class AccountChangeWidget extends StatelessWidget {
  final double? percentageChange;
  final double totalChange;
  final MainAxisAlignment mainAxisAlignment;

  const AccountChangeWidget({
    super.key,
    required this.totalChange,
    this.percentageChange,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

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
              TextWidget(
                referenceSize: .85,
                text: "(${formatPercentage(percentageChange!)})",
                style: TextStyle(color: changeColor),
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
