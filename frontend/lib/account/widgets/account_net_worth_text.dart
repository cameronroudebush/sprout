import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';

/// Widget that displays the current accounts value
class AccountNetWorthText extends ConsumerWidget {
  final Account account;
  final ChartRangeEnum range;
  final EntityHistoryDataPoint? frame;
  final bool showRangeSelector;

  const AccountNetWorthText({
    super.key,
    required this.account,
    required this.range,
    required this.frame,
    this.showRangeSelector = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final value = account.balance;
    final balanceColor = account.isDebt ? (-value).toBalanceColor(theme) : value.toBalanceColor(theme);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Text(
              formatter.format(value),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: balanceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SproutChangeWidget(
              totalChange: frame?.valueChange,
              percentageChange: frame?.percentChange,
              mainAxisAlignment: MainAxisAlignment.start,
              useExtendedPeriodString: false,
              period: range,
              fontSize: 11,
              invert: account.isDebt,
            ),
          ],
        ),
        if (showRangeSelector) const ChartRangeSelector(),
      ],
    );
  }
}
