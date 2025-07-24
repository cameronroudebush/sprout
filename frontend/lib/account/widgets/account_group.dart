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

  const AccountGroupWidget({super.key, required this.accounts, required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConfigProvider, NetWorthProvider>(
      builder: (context, configProvider, netWorthProvider, child) {
        final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);
        final groupDayChange = netWorthProvider.historicalAccountData
            ?.where((element) => accounts.any((account) => account.id == element.accountId))
            .fold(0.0, (sum, element) => sum + (element.getValueByFrame(netWorthPeriod) ?? 0.0));
        final theme = Theme.of(context);
        final balanceColor = getBalanceColor(totalBalance, theme);

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Display header row information
              Padding(
                padding: EdgeInsetsGeometry.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      referenceSize: 1.25,
                      text: type.toCapitalized,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 4,
                        children: [
                          // Group balance
                          TextWidget(
                            referenceSize: 1.15,
                            text: currencyFormatter.format(totalBalance),
                            style: TextStyle(fontWeight: FontWeight.bold, color: balanceColor),
                          ),
                          if (groupDayChange != null) AccountChangeWidget(percentageChange: groupDayChange),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Display every account with a separator
              Padding(
                padding: EdgeInsetsGeometry.directional(start: 12, end: 12),
                child: Column(
                  children: [
                    ...accounts.expand(
                      (account) => [
                        AccountWidget(account: account, netWorthPeriod: netWorthPeriod),
                        if (account != accounts.last) const Divider(height: 1),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
