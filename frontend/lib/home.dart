import 'package:flutter/material.dart';
import 'package:sprout/accounts.dart';
import 'package:sprout/net.dart';

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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .8,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Net Worth Section
              NetWorthWidget(),
              SizedBox(height: 24.0), // Spacing between sections
              // Accounts Section
              AccountsPage(),
              SizedBox(height: 24.0), // Spacing between sections
              // Transactions Section
              // TransactionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
