import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';

class TransactionsSection extends StatelessWidget {
  const TransactionsSection({super.key});

  // Dummy data for transactions
  final List<Map<String, dynamic>> transactions = const [
    {'description': 'Groceries', 'amount': -75.20, 'date': '2025-07-01', 'category': 'Food'},
    {'description': 'Salary', 'amount': 3500.00, 'date': '2025-06-28', 'category': 'Income'},
    {'description': 'Online Subscription', 'amount': -12.99, 'date': '2025-06-27', 'category': 'Entertainment'},
    {'description': 'Coffee Shop', 'amount': -5.50, 'date': '2025-06-27', 'category': 'Food'},
    {'description': 'Utility Bill', 'amount': -120.00, 'date': '2025-06-26', 'category': 'Bills'},
    {'description': 'Dinner Out', 'amount': -45.00, 'date': '2025-06-25', 'category': 'Food'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Recent Transactions', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12.0),
        // Using ListView.builder for potentially long lists of transactions
        // Ensure it's wrapped in a Container with a fixed height or use shrinkWrap/NeverScrollableScrollPhysics
        // Here, we use Column with children for simplicity, similar to AccountsSection.
        // For a very long list, consider a custom scroll view or a dedicated page.
        ...transactions.map((transaction) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: ListTile(
              leading: Icon(
                transaction['amount'] >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                color: transaction['amount'] >= 0 ? Colors.green[700] : Colors.red[700],
              ),
              title: Text(transaction['description'], style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${transaction['date']} - ${transaction['category']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Text(
                currencyFormatter.format(transaction["amount"].abs()), // Show absolute value
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction['amount'] >= 0 ? Colors.green[700] : Colors.red[700],
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('${transaction['description']} transaction tapped!')));
              },
            ),
          );
        }).toList(),
        const SizedBox(height: 12.0),
        Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('View all transactions tapped!')));
            },
            child: const Text(
              'View All Transactions',
              style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
