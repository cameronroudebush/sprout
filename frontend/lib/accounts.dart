import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/account.dart';
import 'package:sprout/model/account.dart';
import 'package:sprout/utils/formatters.dart';
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
    await accountAPI.getProviderAccounts();
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
          // Using ListView.builder inside a Column requires it to be shrinkWrap and have physics set to NeverScrollableScrollPhysics
          // or wrap it in a Container with a fixed height. For a simple list, Column with children is also fine.
          // Here, using Column with individual ListTiles for simplicity and to avoid nested scrolling issues with SingleChildScrollView.
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
                const SizedBox(height: 20.0),
                Center(
                  child: ButtonWidget(
                    text: "Add New Account",
                    minSize: 400,
                    icon: Icons.add,
                    onPressed: () => {print("press")},
                  ),
                ),
              ],
            )
          else
            ..._accounts.map((account) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(account.icon, color: Colors.blueGrey),
                  title: Text(
                    account.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    currencyFormatter.format(account.balance),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: account.balance >= 0
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${account.name} tapped!')),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}
