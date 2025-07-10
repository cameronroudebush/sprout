import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/account.dart';
import 'package:sprout/utils/formatters.dart';
import 'package:sprout/widgets/text.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<dynamic> _accounts = [];

  /// Handles setting the current accounts
  @override
  void initState() {
    super.initState();
    setAccounts();
  }

  Future<void> setAccounts() async {
    final accountAPI = Provider.of<AccountAPI>(context, listen: false);
    final accounts = await accountAPI.getAccounts();
    setState(() {
      _accounts = accounts;
    });
  }

  /// Based on the type, returns the icon to use
  IconData getIcon(String type) {
    return Icons.trending_up;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextWidget(
          referenceSize: 1,
          text: 'Accounts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        // Using ListView.builder inside a Column requires it to be shrinkWrap and have physics set to NeverScrollableScrollPhysics
        // or wrap it in a Container with a fixed height. For a simple list, Column with children is also fine.
        // Here, using Column with individual ListTiles for simplicity and to avoid nested scrolling issues with SingleChildScrollView.
        ..._accounts.map((account) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: Icon(getIcon(account["type"]), color: Colors.blueGrey),
              title: Text(
                account['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                currencyFormatter.format(account["balance"]),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: account['balance'] >= 0
                      ? Colors.green[700]
                      : Colors.red[700],
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${account['name']} tapped!')),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
