import 'package:flutter/material.dart';
import 'package:sprout/accounts.dart';
import 'package:sprout/net.dart';
import 'package:sprout/widgets/app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SproutAppBar(
        toolbarHeight: MediaQuery.of(context).size.height * .075,
      ),
      body: SingleChildScrollView(
        child: Center(
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
                  NetWorthCard(),
                  SizedBox(height: 24.0), // Spacing between sections
                  // Accounts Section
                  AccountsSection(),
                  SizedBox(height: 24.0), // Spacing between sections
                  // Transactions Section
                  // TransactionsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
