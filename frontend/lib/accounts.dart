import 'package:flutter/material.dart';
import 'package:sprout/utils/formatters.dart';

class AccountsSection extends StatelessWidget {
  const AccountsSection({super.key});

  // Dummy data for accounts
  final List<Map<String, dynamic>> accounts = const [
    {
      'name': 'Checking Account',
      'balance': 5234.50,
      'icon': Icons.account_balance,
    },
    {'name': 'Savings Account', 'balance': 100000.00, 'icon': Icons.savings},
    {
      'name': 'Credit Card (Visa)',
      'balance': -1250.75,
      'icon': Icons.credit_card,
    },
    {
      'name': 'Investment Portfolio',
      'balance': 21361.92,
      'icon': Icons.trending_up,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'My Accounts',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        // Using ListView.builder inside a Column requires it to be shrinkWrap and have physics set to NeverScrollableScrollPhysics
        // or wrap it in a Container with a fixed height. For a simple list, Column with children is also fine.
        // Here, using Column with individual ListTiles for simplicity and to avoid nested scrolling issues with SingleChildScrollView.
        ...accounts.map((account) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: Icon(account['icon'], color: Colors.blueGrey),
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
