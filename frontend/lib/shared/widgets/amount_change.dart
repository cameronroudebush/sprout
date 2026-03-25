import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A generic widget to display financial change (price or percentage) with semantic coloring
class SproutChangeWidget extends ConsumerWidget {
  final num? percentageChange;
  final num? totalChange;
  final MainAxisAlignment mainAxisAlignment;
  final ChartRangeEnum? period;
  final bool useExtendedPeriodString;
  final bool showPercentage;
  final bool showValue;
  final double fontSize;

  /// If we should inverse the value and percentage changes
  final bool invert;

  const SproutChangeWidget(
      {super.key,
      required this.totalChange,
      this.percentageChange,
      this.period,
      this.useExtendedPeriodString = true,
      this.mainAxisAlignment = MainAxisAlignment.end,
      this.showPercentage = true,
      this.showValue = true,
      this.fontSize = 12,
      this.invert = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

    if (totalChange == null && percentageChange == null) return const SizedBox.shrink();

    // Use our extension for semantic coloring
    final total = (totalChange ?? 0) * (invert ? -1 : 1);
    final percent = (percentageChange ?? 0) * (invert ? -1 : 1);
    final changeColor = (total).toBalanceColor(theme);
    final icon = (total).toChangeIcon();

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: changeColor, size: fontSize + 2),
        const SizedBox(width: 4),
        Flexible(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              if (showValue && totalChange != null)
                Text(
                  total.toCurrency(isPrivate),
                  style: TextStyle(color: changeColor, fontSize: fontSize),
                ),
              if (showPercentage && percentageChange != null)
                Text(
                  _formatPercent(percent, showValue),
                  style: TextStyle(color: changeColor, fontSize: showValue ? fontSize - 2 : fontSize),
                ),
              if (period != null)
                Text(
                  ChartRangeUtility.asPretty(period!, useExtendedPeriodString: useExtendedPeriodString),
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formats our percentage for rendering
  String _formatPercent(num val, bool showParentheses) {
    if (val == double.infinity) return "(∞%)";
    if (val.isNaN) return "";
    final sign = val > 0 ? "+" : "";
    final returnVal = "$sign${val.toStringAsFixed(2)}%";
    if (showParentheses) {
      return "($returnVal)";
    } else {
      return returnVal;
    }
  }
}
