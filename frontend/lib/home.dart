import 'package:flutter/material.dart';
import 'package:sprout/accounts.dart';
import 'package:sprout/net.dart';
import 'package:sprout/transactions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 128,
        title: Image.asset(
          'assets/logo/color-transparent-no-tag.png',
          width: 320,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        centerTitle: true,
        elevation: 0, // Remove shadow
        actions: [],
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: .5,
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
                TransactionsSection(),
              ],
            ),
          ),
        ),
      ),
      // Optional: Add a Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle new transaction/add button press
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add new item tapped!')));
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
