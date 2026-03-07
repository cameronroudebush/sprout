import 'package:flutter/material.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Recent Transactions", style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.shopping_cart)),
              title: const Text("Grocery Store"),
              subtitle: const Text("March 7, 2026"),
              trailing: const Text("-\$84.12", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Center(child: Text("View All Transactions")),
          ),
        ],
      ),
    );
  }
}
