import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/accounts_display.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        final linkedAccounts = accountProvider.linkedAccounts;
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: TextWidget(
                  referenceSize: 2,
                  text: 'Accounts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12.0),
              if (linkedAccounts.isEmpty)
                Column(
                  children: [
                    Center(
                      child: TextWidget(
                        referenceSize: 1.5,
                        text: 'No accounts found. Add an account to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                )
              else
                AccountsWidget(accounts: linkedAccounts),
              const SizedBox(height: 20.0),
              Center(
                child: ButtonWidget(
                  text: "Add New Account",
                  minSize: 400,
                  icon: Icons.add,
                  onPressed: () async {
                    await showDialog(context: context, builder: (_) => AddAccountDialog());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
