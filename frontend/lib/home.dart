import 'package:flutter/material.dart';
import 'package:sprout/accounts.dart';
import 'package:sprout/api/client.dart';
import 'package:sprout/net.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required JwtApiClient apiClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * .075,
        title: Image.asset(
          'assets/logo/color-transparent-no-tag.png',
          width: MediaQuery.of(context).size.height * .2,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        centerTitle: true,
        elevation: 0, // Remove shadow
        actions: [],
        backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: Container(
            color: Theme.of(context).colorScheme.secondary.withAlpha(100),
            height: 8.0,
          ),
        ),
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
