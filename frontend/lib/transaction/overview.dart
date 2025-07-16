import 'package:flutter/material.dart';
import 'package:sprout/transaction/widgets/recent_transactions.dart';
import 'package:sprout/transaction/widgets/summary.dart';

class TransactionsOverviewPage extends StatelessWidget {
  const TransactionsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TransactionSummaryCard(),
          const SizedBox(height: 16.0),

          const RecentTransactionsCard(),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
