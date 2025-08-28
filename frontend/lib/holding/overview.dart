import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account_row.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/holding/models/holding.dart';
import 'package:sprout/holding/provider.dart';
import 'package:sprout/holding/widgets/holding.dart';
import 'package:sprout/net-worth/provider.dart';

/// The overview page for rendering the holdings for each account
class HoldingsOverview extends StatelessWidget {
  const HoldingsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<HoldingProvider, AccountProvider, ConfigProvider, NetWorthProvider>(
      builder: (context, holdingProvider, accountProvider, configProvider, netWorthProvider, child) {
        final mediaQuery = MediaQuery.of(context).size;
        final Map<String, List<Holding>> holdingsByAccount = {};
        for (var holding in holdingProvider.holdings) {
          holdingsByAccount.putIfAbsent(holding.account.id, () => []).add(holding);
        }

        // Loading/no holdings indicator
        if (holdingProvider.isLoading || holdingProvider.holdings.isEmpty) {
          return SizedBox(
            height: mediaQuery.height * .7,
            child: Center(
              child: holdingProvider.isLoading
                  ? CircularProgressIndicator()
                  : TextWidget(
                      referenceSize: 2,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      text: 'No holdings found',
                    ),
            ),
          );
        }

        return Column(
          children: [
            // Last priced info
            SproutCard(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 12),
                child: Column(
                  children: [
                    TextWidget(
                      text: "Last Priced",
                      referenceSize: 2,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 1),
                    Padding(
                      padding: EdgeInsetsGeometry.only(top: 12),
                      child: TextWidget(text: configProvider.getLastSyncStatus(), referenceSize: 1.25),
                    ),
                  ],
                ),
              ),
            ),
            // Holdings
            ...holdingsByAccount.entries.map((entry) {
              final account = accountProvider.linkedAccounts.firstWhere((element) => element.id == entry.key);
              return SproutCard(
                child: Column(
                  spacing: 0,
                  children: [
                    // Account Row
                    AccountRowWidget(
                      account: account,
                      netWorthPeriod: ChartRange.oneDay,
                      displayStats: true,
                      displayTotals: true,
                      allowClick: false,
                      showPercentage: true,
                      showPeriod: true,
                    ),
                    const Divider(height: 1),
                    // Holdings
                    Column(
                      children: entry.value.map((holding) {
                        return Column(
                          children: [
                            HoldingWidget(holding: holding),
                            if (entry.value.last != holding) const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
