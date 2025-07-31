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
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const TransactionSummaryCard(), const RecentTransactionsCard(rowsPerPage: 12)],
      ),
    );
  }
}
