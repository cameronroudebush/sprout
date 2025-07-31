import 'package:flutter/material.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/account/widgets/account_group.dart';
import 'package:sprout/net-worth/models/chart_range.dart';

/// Uses the AccountGroupWidget to render all of the given accounts after sorting them and migrating them by type.
class AccountGroupsWidget extends StatelessWidget {
  final List<Account> accounts;
  final ChartRange netWorthPeriod;
  final void Function(Account)? onAccountClick;
  final Set<Account>? selectedAccounts;

  /// If stats should be displayed (percentage changes etc)
  final bool displayStats;

  /// If we should display the total values
  final bool displayTotals;

  /// If the account groups should be collapsible
  final bool allowCollapse;

  /// If the groups should render in a card
  final bool applyCard;

  const AccountGroupsWidget({
    super.key,
    required this.accounts,
    required this.netWorthPeriod,
    this.onAccountClick,
    this.displayStats = true,
    this.displayTotals = true,
    this.selectedAccounts,
    required this.allowCollapse,
    required this.applyCard,
  });

  /// Given a list of accounts, sorts and groups them for display
  List<MapEntry<String, List<Account>>> _getSortedGroupedAccounts(List<Account> accounts) {
    // Group accounts by type
    final Map<String, List<Account>> accountsByType = {};
    for (var account in accounts) {
      accountsByType.putIfAbsent(account.type, () => []).add(account);
    }
    // Order accounts by balance
    accountsByType.forEach((key, value) {
      value.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    });

    // Define the desired order of account types
    final List<String> accountTypeOrder = ['depository', 'investment', 'credit', 'loan'];

    // Sort the map entries based on the custom order
    final List<MapEntry<String, List<Account>>> sortedAccountsEntries = accountsByType.entries.toList();

    sortedAccountsEntries.sort((a, b) {
      final int indexA = accountTypeOrder.indexOf(a.key);
      final int indexB = accountTypeOrder.indexOf(b.key);
      if (indexA == -1 && indexB == -1) {
        return a.key.compareTo(b.key);
      } else if (indexA == -1) {
        return 1;
      } else if (indexB == -1) {
        return -1;
      }
      return indexA.compareTo(indexB);
    });
    return sortedAccountsEntries;
  }

  @override
  Widget build(BuildContext context) {
    final sortedAccountEntries = _getSortedGroupedAccounts(accounts);
    final totalAssets = accounts.fold(0.0, (sum, account) => sum + (account.balance > 0 ? account.balance : 0));
    final totalDebts = accounts.fold(0.0, (sum, account) => sum + (account.balance < 0 ? account.balance : 0));

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...sortedAccountEntries.map((entry) {
            double totalNetWorth;

            if (entry.key == "loan" || entry.key == "credit") {
              totalNetWorth = totalDebts;
            } else {
              totalNetWorth = totalAssets;
            }

            return Padding(
              padding: EdgeInsetsGeometry.directional(start: 0, end: 0),
              child: AccountGroupWidget(
                netWorthPeriod: netWorthPeriod,
                accounts: entry.value,
                type: entry.key,
                totalNetWorth: totalNetWorth,
                onAccountClick: onAccountClick,
                displayStats: displayStats,
                displayTotals: displayTotals,
                selectedAccounts: selectedAccounts,
                allowCollapse: allowCollapse,
                applyCard: applyCard,
              ),
            );
          }),
        ],
      ),
    );
  }
}
