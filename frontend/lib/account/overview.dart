import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/accounts.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account_group.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/app_bar.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/tabs.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';
import 'package:sprout/user/provider.dart';

/// The main accounts display that contains the chart along side the actual accounts list
class AccountsOverview extends StatefulWidget {
  const AccountsOverview({super.key});

  @override
  State<AccountsOverview> createState() => _AccountsOverviewState();
}

class _AccountsOverviewState extends State<AccountsOverview> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Consumer3<UserProvider, AccountProvider, NetWorthProvider>(
      builder: (context, userProvider, accountProvider, netWorthProvider, child) {
        final accountTypes = ["depository", "investment", "loan", "credit"];
        final accountTypesContent = accountTypes.map((a) {
          return _buildTabContent(context, a, userProvider, accountProvider, netWorthProvider);
        }).toList();
        return SizedBox(
          height: mediaQuery.height - SproutAppBar.getHeightFromScreenHeight(mediaQuery.height),
          child: ScrollableTabsWidget(accountTypes.map((el) => formatAccountType(el)).toList(), accountTypesContent),
        );
      },
    );
  }

  // Helper method to create the tab content for each account type
  Widget _buildTabContent(
    BuildContext context,
    String accountType,
    UserProvider provider,
    AccountProvider accountProvider,
    NetWorthProvider netWorthProvider,
  ) {
    final chartRange = provider.userDefaultChartRange;
    final accountsForType = accountProvider.linkedAccounts.where((element) => element.type == accountType).toList();
    // Build the net worth data for these accounts
    final historyForRange = accountsForType
        .map(
          (account) =>
              netWorthProvider.historicalAccountData?.firstWhereOrNull((element) => element.connectedId == account.id),
        )
        .nonNulls
        .toList();

    // Flatten the data so the line chart can display the combined net worth for these accounts
    final Map<DateTime, double> data = {};
    for (final entityHistory in historyForRange) {
      final history = entityHistory.getValueByFrame(chartRange).history;
      for (final historyPoint in history.entries) {
        data.update(historyPoint.key, (value) => value + historyPoint.value, ifAbsent: () => historyPoint.value);
      }
    }

    final groupCalc = AccountGroupWidget.calculate(historyForRange, accountsForType, chartRange);
    final netWorth = groupCalc.totalBalance;
    double totalChange = groupCalc.totalChange;
    final percentageChange = groupCalc.percentageChange;
    if (accountType == "loan" || accountType == "credit") totalChange *= -1;

    return Column(
      children: [
        // Render net worth chart
        SproutCard(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 12, left: 12, bottom: 12),
            child: Column(
              spacing: 12,
              children: data.isEmpty
                  ? [
                      const SizedBox(
                        height: 150,
                        child: Center(child: TextWidget(text: "No data for accounts")),
                      ),
                    ]
                  : [
                      NetWorthTextWidget(
                        chartRange,
                        netWorth,
                        percentageChange,
                        totalChange,
                        title: "${formatAccountType(accountType)} Accounts Value",
                      ),
                      SproutLineChart(
                        data: data,
                        chartRange: chartRange,
                        formatValue: (value) => getFormattedCurrency(value),
                      ),
                      ChartRangeSelector(
                        selectedChartRange: chartRange,
                        onRangeSelected: (value) {
                          provider.updateChartRange(value);
                        },
                      ),
                    ],
            ),
          ),
        ),
        // Render accounts
        AccountsWidget(
          allowCollapse: false,
          netWorthPeriod: chartRange,
          accountType: accountType,
          showGroupTitles: false,
        ),
      ],
    );
  }
}
