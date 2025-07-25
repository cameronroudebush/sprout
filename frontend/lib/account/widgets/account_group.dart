import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/models/account.dart'; // Assuming you have this model
import 'package:sprout/account/widgets/account.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/provider.dart';

/// A widget used to display a grouping of accounts for a specific type
class AccountGroupWidget extends StatelessWidget {
  final List<Account> accounts;
  final String type;
  final String netWorthPeriod = "last7Days";
  final double totalNetWorth;
  final void Function(Account)? onAccountClick;
  final Set<Account>? selectedAccounts;

  /// If stats should be displayed (percentage changes etc)
  final bool displayStats;

  /// If we should display the total values
  final bool displayTotals;

  const AccountGroupWidget({
    super.key,
    required this.accounts,
    required this.type,
    required this.totalNetWorth,
    this.onAccountClick,
    required this.displayStats,
    required this.displayTotals,
    this.selectedAccounts,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConfigProvider, NetWorthProvider>(
      builder: (context, configProvider, netWorthProvider, child) {
        final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);

        double groupAmountChange = 0;
        // Filter the historical data once.
        final filteredGroupData = netWorthProvider.historicalAccountData?.where(
          (element) => accounts.any((account) => account.id == element.accountId),
        );

        // Use a for-in loop to iterate through the filtered data and accumulate sums.
        if (filteredGroupData != null) {
          for (final element in filteredGroupData) {
            final valueByFrame = element.getValueByFrame(netWorthPeriod);
            if (valueByFrame.percentChange != null) {
              groupAmountChange += valueByFrame.valueChange;
            }
          }
        }
        double? groupPercentChange = (groupAmountChange / totalBalance) * 100;

        /// The percent of total net worth
        final percentOfType = (totalBalance / totalNetWorth) * 100;
        final theme = Theme.of(context);
        final balanceColor = getBalanceColor(totalBalance, theme);

        // Simplify the types and perform some extra handling on debts
        String simpleType;
        if (type == "loan" || type == "credit") {
          simpleType = "debts";
          groupAmountChange *= -1;
        } else {
          simpleType = "assets";
        }

        /// A cleaned up type name for display
        String adjustedType = type;
        if (adjustedType.toLowerCase() == "credit") {
          adjustedType = "Credit Card";
        } else if (adjustedType.toLowerCase() == "depository") {
          adjustedType = "Cash";
        } else {
          adjustedType = adjustedType.toCapitalized;
        }

        return ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(24),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Display header row information
                Padding(
                  padding: EdgeInsetsGeometry.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              referenceSize: 1.25,
                              text: adjustedType,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (displayStats)
                              AccountChangeWidget(
                                percentageChange: groupPercentChange,
                                totalChange: groupAmountChange,
                                mainAxisAlignment: MainAxisAlignment.start,
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 4,
                          children: [
                            // Group balance
                            if (displayTotals)
                              TextWidget(
                                referenceSize: 1.15,
                                text: currencyFormatter.format(totalBalance),
                                style: TextStyle(fontWeight: FontWeight.bold, color: balanceColor),
                              ),
                            // Percent of total net worth
                            if (displayStats)
                              TextWidget(
                                referenceSize: .9,
                                text: "${formatPercentage(percentOfType)} of $simpleType",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Column(
                  children: [
                    ...accounts.expand((account) {
                      final isSelected = selectedAccounts?.contains(account) ?? false;

                      return [
                        Container(
                          decoration: BoxDecoration(
                            border: isSelected == false
                                ? null
                                : BoxBorder.all(width: 3, color: theme.colorScheme.secondary),
                            borderRadius: accounts.last == account
                                ? BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
                                : null,
                          ),
                          child: Column(
                            children: [
                              AccountWidget(
                                account: account,
                                netWorthPeriod: netWorthPeriod,
                                displayTotals: displayTotals,
                                displayStats: displayStats,
                                onClick: onAccountClick == null ? null : () => onAccountClick!(account),
                                isSelected: isSelected,
                              ),
                              if (account != accounts.last) const Divider(height: 1),
                            ],
                          ),
                        ),
                      ];
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
