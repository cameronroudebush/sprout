import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';

/// A widget used to display the percentage change of an account with icons and coloring
class AccountChangeWidget extends StatelessWidget {
  final double? percentageChange;

  const AccountChangeWidget({super.key, this.percentageChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (percentageChange != null) {
      final changeColor = getBalanceColor(percentageChange!, theme);
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(getChangeIcon(percentageChange!), color: changeColor, size: 16),
          SizedBox(width: 4),
          TextWidget(
            text: formatPercentage(percentageChange!),
            style: TextStyle(color: changeColor),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
