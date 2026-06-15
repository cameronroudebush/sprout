import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/widgets/account_group.dart';
import 'package:sprout/account/widgets/accounts_empty.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/charts/util/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Renders a grouped overview of all user accounts.
///
/// Includes a visual breakdown of Assets vs. Debts and uses expandable
/// sections to maintain a clean, scannable interface.
class AccountSummaryView extends ConsumerWidget {
  final bool collapsible;

  /// The accounts to render
  final List<Account> accounts;

  /// If each grouping should be rendered as it's own card. We use this heavily to determine if this is displayed on the dashboard vs it's own page
  final bool individualCards;

  const AccountSummaryView({super.key, required this.accounts, this.individualCards = true, this.collapsible = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = AccountExtensions.groupConfig;
    final historyAsync = ref.watch(historicalAccountDataProvider);
    final selectedRange = ref.watch(userConfigProvider).value?.netWorthRange ?? ChartRangeEnum.oneDay;

    // Handle empty state
    if (accounts.isEmpty) return AccountsEmptyWidget(showRedirect: !individualCards);

    final groupedAccounts =
        config.keys.where((type) => accounts.any((a) => a.type == type) && config[type] != null).map((type) {
      final groupAccounts = accounts.where((a) => a.type == type).toList();
      final ui = config[type]!;

      // Calculate the weighted aggregate percentage change for this group
      double totalGroupValueChange = 0;
      double totalWeightedPercent = 0;
      double totalBalance = 0;

      historyAsync.whenData((historyList) {
        if (historyList == null) return;

        // Filter histories for accounts in this group
        final groupHistories = historyList.where((h) => groupAccounts.any((a) => a.id == h.connectedId));

        for (final h in groupHistories) {
          final dataPoint = h.getValueByFrame(selectedRange);
          final account = groupAccounts.firstWhere((a) => a.id == h.connectedId);
          final multiplier = account.isDebt ? -1.0 : 1.0;

          final currentBalance = account.balance.abs();
          final changeAmount = dataPoint.valueChange.toDouble().abs();
          final weight = currentBalance > 0 ? currentBalance : changeAmount;
          final percentChange = (dataPoint.percentChange?.toDouble() ?? 0) * multiplier;

          totalGroupValueChange += dataPoint.valueChange.toDouble() * multiplier;
          totalWeightedPercent += (percentChange * weight);
          totalBalance += weight;
        }
      });

      final groupPercentChange = totalBalance > 0 ? (totalWeightedPercent / totalBalance) : 0.0;

      return AccountGroupSection(
        title: ui.title,
        accounts: groupAccounts,
        accentColor: ui.color,
        isNegative: ui.isNegative,
        initiallyExpanded: individualCards,
        renderAsCard: individualCards,
        percentChange: groupPercentChange,
        totalChange: totalGroupValueChange,
        selectedRange: selectedRange,
        historyList: historyAsync.value,
        allowExpansion: collapsible,
        onAccountClick: (acc) => NavigationProvider.redirect('accounts/details', queryParameters: {'id': acc.id}),
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (individualCards)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ChartRangeSelector(large: true),
          ),
        if (individualCards)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groupedAccounts.length,
            itemBuilder: (context, index) => groupedAccounts[index],
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...groupedAccounts
                  .mapIndexed(
                    (index, widget) => [
                      widget,
                      if (index < groupedAccounts.length - 1) const Divider(height: 0.5, indent: 16, endIndent: 16),
                    ],
                  )
                  .expand((widgets) => widgets),
            ],
          ),
      ],
    );
  }
}
