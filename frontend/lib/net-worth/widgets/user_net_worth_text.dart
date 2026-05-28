import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';

/// A widget that just display's the users current net worth
class UserNetWorthText extends ConsumerWidget {
  final String? title;
  final ChartRangeEnum range;
  final EntityHistoryDataPoint? frame;
  final bool invert;
  final bool showRangeSelector;

  const UserNetWorthText({
    super.key,
    this.title = "Net Worth",
    required this.range,
    required this.frame,
    this.invert = false,
    this.showRangeSelector = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final netWorth = ref.watch(totalNetWorthProvider);
    final value = netWorth.value?.value ?? -0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              formatter.format(value),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: value.toBalanceColor(theme),
              ),
            ),
            SproutChangeWidget(
              totalChange: frame?.valueChange,
              percentageChange: frame?.percentChange,
              mainAxisAlignment: MainAxisAlignment.start,
              useExtendedPeriodString: false,
              period: range,
              fontSize: 11,
              invert: invert,
            ),
          ],
        ),
        if (showRangeSelector) const ChartRangeSelector(),
      ],
    );
  }
}
