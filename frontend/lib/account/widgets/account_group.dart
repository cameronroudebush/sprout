import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/account_error_icon.dart';
import 'package:sprout/account/widgets/account_item_row.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/card.dart';

/// Renders a grouping of accounts with the given data and configuration
class AccountGroupSection extends ConsumerWidget {
  /// The account group name
  final String title;

  /// The list of accounts in this group
  final List<Account> accounts;

  /// If the user is in private mode
  final bool isPrivate;

  /// The color of this grouping
  final Color accentColor;

  /// If this is a liability account
  final bool isNegative;

  /// If we should render this group in it's own card
  final bool renderAsCard;

  /// If this expansion should be initially expanded
  final bool initiallyExpanded;

  /// If we should allow expansion of the tiles
  final bool allowExpansion;

  // Properties for change rendering
  final List<EntityHistory>? historyList;
  final num? percentChange;
  final num? totalChange;
  final ChartRangeEnum selectedRange;

  // Additional properties for selection and accordion control
  final Set<Account>? selectedAccounts;
  final void Function(Account)? onAccountClick;

  const AccountGroupSection({
    super.key,
    required this.title,
    required this.accounts,
    required this.isPrivate,
    required this.accentColor,
    required this.selectedRange,
    this.isNegative = false,
    this.renderAsCard = false,
    this.initiallyExpanded = true,
    this.percentChange,
    this.totalChange,
    this.historyList,
    this.selectedAccounts,
    this.onAccountClick,
    this.allowExpansion = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final total = accounts.fold(0.0, (sum, a) => sum + a.balance);
    final bool groupHasError = accounts.any((a) => a.institution.hasError);

    final innerContent = Padding(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          enabled: allowExpansion,
          visualDensity: VisualDensity.compact,
          leading: Icon(Icons.circle, color: accentColor, size: 12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              // Error indicator for the group
              SproutErrorIcon(hasError: groupHasError, size: 14),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(total),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: total.toBalanceColor(theme),
                ),
              ),
              if (percentChange != null)
                SproutChangeWidget(
                  totalChange: totalChange,
                  percentageChange: percentChange,
                  period: selectedRange,
                  fontSize: 12,
                  useExtendedPeriodString: false,
                ),
            ],
          ),
          children: [
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...accounts.map((acc) {
              // Find history for this specific account
              final history = historyList?.firstWhereOrNull((h) => h.connectedId == acc.id);
              final dataPoint = history?.getValueByFrame(selectedRange);
              final isSelected = selectedAccounts?.contains(acc) ?? false;
              final hasError = acc.institution.hasError;

              // Main row content
              Widget row = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AccountItemRow(
                      acc,
                      isPrivate,
                      percentChange: dataPoint?.percentChange?.toDouble(),
                      valueChange: dataPoint?.valueChange.toDouble(),
                      period: selectedRange,
                      onAccountClick: onAccountClick != null ? () => onAccountClick!(acc) : null,
                    ),
                    // Display the error badge if the institution has an error
                    Positioned(left: -10, top: 2, child: SproutErrorIcon(hasError: hasError, size: 12)),
                  ],
                ),
              );

              if (selectedAccounts != null) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (isSelected)
                        SizedBox(
                          width: 24,
                          child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                        ),
                      Expanded(child: row),
                    ],
                  ),
                );
              }

              return row;
            }),
          ],
        ),
      ),
    );

    if (renderAsCard) {
      return SproutCard(child: innerContent);
    } else {
      return innerContent;
    }
  }
}
