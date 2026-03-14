import 'package:flutter/material.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/amount_change.dart';

/// This widget is used to render a singular account item in a row
class AccountItemRow extends StatelessWidget {
  /// The account to render
  final Account account;

  /// If the user is in private mode
  final bool isPrivate;

  /// The percentage change for the selected period
  final double? percentChange;

  /// The absolute value change for the selected period
  final double? valueChange;

  /// The period these changes represent (e.g., 1D, 1W)
  final ChartRangeEnum? period;

  /// What to do when the account is clicked
  final void Function()? onAccountClick;

  const AccountItemRow(
    this.account,
    this.isPrivate, {
    super.key,
    this.percentChange,
    this.valueChange,
    this.period,
    this.onAccountClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onAccountClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          spacing: 8,
          children: [
            AccountLogo(account, width: 32, height: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(account.institution.name, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  account.balance.toCurrency(isPrivate),
                  style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
                SproutChangeWidget(
                  percentageChange: percentChange,
                  totalChange: valueChange,
                  period: period ?? ChartRangeEnum.oneDay,
                  fontSize: 12,
                ),
              ],
            ),
            Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
