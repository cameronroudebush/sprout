import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/account.dart';
import 'package:sprout/dialog/add_account.dart';
import 'package:sprout/model/account.dart';
import 'package:sprout/widgets/accounts.dart';
import 'package:sprout/widgets/button.dart';
import 'package:sprout/widgets/text.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Account> _accounts = [];

  /// Handles setting the current accounts
  @override
  void initState() {
    super.initState();
    setAccounts();
  }

  Future<void> setAccounts() async {
    final accountAPI = Provider.of<AccountAPI>(context, listen: false);
    final accounts = await accountAPI.getAccounts() as List<Account>;
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: TextWidget(
              referenceSize: 3,
              text: 'Accounts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12.0),
          if (_accounts.isEmpty)
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
            AccountsWidget(accounts: _accounts),
          const SizedBox(height: 20.0),
          Center(
            child: ButtonWidget(
              text: "Add New Account",
              minSize: 400,
              icon: Icons.add,
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => AddAccountDialog(),
                );
                setAccounts();
              },
            ),
          ),
        ],
      ),
    );
  }
}
