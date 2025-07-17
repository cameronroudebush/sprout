import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/transaction/provider.dart';

// A summary card for this month
class TransactionSummaryCard extends StatelessWidget {
  const TransactionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const TextWidget(
                    referenceSize: 2,
                    text: 'Monthly Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: TextWidget(
                    referenceSize: 1,
                    text: 'Last 30 days',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 10),
                // Consume the transactions to display
                Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                    int totalTransactions = provider.totalTransactionCount;
                    double averageAmount = provider.transactionStats?.averageTransactionCost ?? 0;
                    double largestExpense = provider.transactionStats?.largestExpense ?? 0;
                    double totalSpend = provider.transactionStats?.totalSpend ?? 0;
                    ;
                    double totalIncome = provider.transactionStats?.totalIncome ?? 0;

                    return Column(
                      children: [
                        _buildSummaryRow('Total Spent', totalSpend),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Total Income', totalIncome, color: Colors.green),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Total Transactions', totalTransactions, format: false, color: null),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Average Transaction', averageAmount),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Largest Expense', largestExpense),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a generic row of summary data that should be displayed
  Widget _buildSummaryRow(String label, dynamic value, {bool format = true, Color? color = Colors.red}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        TextWidget(
          referenceSize: 1,
          text: format ? currencyFormatter.format(value) : "$value",
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
