import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/accounts.dart';
import 'package:sprout/net-worth/widgets/overview.dart';
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
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final chartRange = provider.userDefaultChartRange;

        return Column(
          children: [
            // Render graph
            NetWorthOverviewWidget(
              showCard: true,
              selectedChartRange: chartRange,
              onRangeSelected: (value) {
                provider.updateChartRange(value);
              },
            ),
            // Render accounts
            AccountsWidget(allowCollapse: false, netWorthPeriod: chartRange),
          ],
        );
      },
    );
  }
}
