import 'package:flutter/material.dart';
import 'package:sprout/account/accounts.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/models/chart_range.dart';
import 'package:sprout/net-worth/widgets/overview.dart';
import 'package:sprout/transaction/widgets/recent_transactions.dart';

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
    final lastTransactionCount = 10;

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
            // Accounts Section
            SproutCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.directional(start: 12, top: 4, bottom: 4),
                    child: TextWidget(
                      referenceSize: 1.5,
                      text: "Accounts",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const Divider(height: 1),
                  AccountsWidget(allowCollapse: true, netWorthPeriod: _selectedChartRange, applyCard: false),
                ],
              ),
            ),
            // Recent Transactions
            // Accounts Section
            SproutCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.directional(start: 12, top: 4, bottom: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          referenceSize: 1.5,
                          text: "Recent Transactions",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.directional(start: 4),
                          child: TextWidget(
                            referenceSize: .9,
                            text: "Last $lastTransactionCount",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  RecentTransactionsCard(applyCard: false, allowPagination: false, rowsPerPage: lastTransactionCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
