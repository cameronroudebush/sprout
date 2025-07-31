import 'package:flutter/material.dart';
import 'package:sprout/account/accounts.dart';
import 'package:sprout/net-worth/models/chart_range.dart';
import 'package:sprout/net-worth/widgets/overview.dart';

/// The main accounts display that contains the chart along side the actual accounts list
class AccountsOverview extends StatefulWidget {
  const AccountsOverview({super.key});

  @override
  State<AccountsOverview> createState() => _AccountsOverviewState();
}

class _AccountsOverviewState extends State<AccountsOverview> {
  /// The current range of data we wish to display
  ChartRange _selectedChartRange = ChartRange.sevenDays;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Render graph
        NetWorthOverviewWidget(
          showCard: false,
          showNetWorthText: false,
          selectedChartRange: _selectedChartRange,
          onRangeSelected: (value) {
            setState(() {
              _selectedChartRange = value;
            });
          },
        ),
        // Render accounts
        AccountsWidget(allowCollapse: false, netWorthPeriod: _selectedChartRange),
      ],
    );
  }
}
