import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/widgets/account_group.dart';
import 'package:sprout/account/widgets/account_total_summary_card.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Renders a grouped overview of all user accounts.
///
/// Includes a visual breakdown of Assets vs. Debts and uses expandable
/// sections to maintain a clean, scannable interface.
class AccountSummaryView extends ConsumerWidget {
  /// The accounts to render
  final List<Account> accounts;

  /// If the user is configured to private mode
  final bool isPrivate;

  /// If each grouping should be rendered as it's own card
  final bool individualCards;

  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const AccountSummaryView({
    super.key,
    required this.accounts,
    required this.isPrivate,
    this.individualCards = true,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = AccountExtensions.groupConfig;
    final historyAsync = ref.watch(historicalAccountDataProvider);
    final selectedRange = ref.watch(userConfigProvider).value?.netWorthRange ?? ChartRangeEnum.oneDay;

    final groupedAccounts = config.keys.map((type) {
      final groupAccounts = accounts.where((a) => a.type == type).toList();
      final ui = config[type];

      if (groupAccounts.isEmpty || ui == null) return const SizedBox.shrink();

      // Calculate the weighted aggregate percentage change for this group
      double totalGroupValueChange = 0;
      double totalWeightedPercent = 0;
      double totalBalance = 0;

      historyAsync.whenData((historyList) {
        if (historyList == null) return;

        // Filter histories for accounts in this group
        final groupHistories = historyList.where((h) => groupAccounts.any((a) => a.id == h.connectedId));

        for (final h in groupHistories) {
          // Use the helper to get the correct data point for the range
          final dataPoint = h.getValueByFrame(selectedRange);

          // Use the balance of the account to weight the percentage
          final account = groupAccounts.firstWhere((a) => a.id == h.connectedId);
          final balance = account.balance.abs();
          totalGroupValueChange += dataPoint.valueChange.toDouble();
          totalWeightedPercent += ((dataPoint.percentChange?.toDouble() ?? 0) * balance);
          totalBalance += balance;
        }
      });

      final groupPercentChange = totalBalance > 0 ? (totalWeightedPercent / totalBalance) : 0.0;

      return AccountGroupSection(
        title: ui.title,
        accounts: groupAccounts,
        isPrivate: isPrivate,
        accentColor: ui.color,
        isNegative: ui.isNegative,
        initiallyExpanded: individualCards,
        renderAsCard: individualCards,
        percentChange: groupPercentChange,
        totalChange: totalGroupValueChange,
        selectedRange: selectedRange,
        historyList: historyAsync.value,
        onAccountClick: (acc) => NavigationProvider.redirect('accounts', queryParameters: {'id': acc.id}),
      );
    }).toList();

    return ListView(
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: [
        TotalSummary(accounts: accounts, isPrivate: isPrivate),
        if (individualCards)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ChartRangeSelector(large: true),
          ),
        if (!individualCards)
          SproutCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...groupedAccounts
                    .mapIndexed(
                      (index, widget) => [
                        widget,
                        if (index < groupedAccounts.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    )
                    .expand((widgets) => widgets),
              ],
            ),
          )
        else
          ...groupedAccounts,
      ],
    );
  }
}
