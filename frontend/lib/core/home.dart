import 'package:flutter/material.dart';
import 'package:sprout/account/overview.dart';
import 'package:sprout/net-worth/net_worth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .9),
        child: Padding(
          padding: EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Net Worth Section
              NetWorthWidget(),
              SizedBox(height: 24.0),
              // Accounts Section
              AccountOverviewPage(),
              SizedBox(height: 24.0),
              // Transactions Section
              // TransactionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
