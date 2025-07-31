import 'package:flutter/material.dart';
import 'package:sprout/account/accounts.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/models/chart_range.dart';
import 'package:sprout/net-worth/widgets/overview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The current range of data we wish to display
  ChartRange _selectedChartRange = ChartRange.sevenDays;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: <Widget>[
            // Net Worth Section
            NetWorthOverviewWidget(
              showCard: true,
              selectedChartRange: _selectedChartRange,
              onRangeSelected: (value) {
                setState(() {
                  _selectedChartRange = value;
                });
              },
            ),
            // NetWorthWidget(),
            // Accounts Section
            SproutCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.directional(start: 12, top: 4),
                    child: TextWidget(
                      referenceSize: 1.5,
                      text: "Accounts",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const Divider(),
                  AccountsWidget(allowCollapse: true, netWorthPeriod: _selectedChartRange, applyCard: false),
                ],
              ),
            ),
            // Transactions Section
            // TransactionsSection(),
          ],
        ),
      ),
    );
  }
}
