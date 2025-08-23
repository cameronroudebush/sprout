import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/transaction/provider.dart';

// A summary card for this month
class TransactionSummaryCard extends StatelessWidget {
  const TransactionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        Widget content;
        if (provider.isLoading) {
          content = Center(child: CircularProgressIndicator());
        } else {
          double averageAmount = provider.transactionStats?.averageTransactionCost ?? 0;
          double largestExpense = provider.transactionStats?.largestExpense ?? 0;

          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
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
                    ],
                  ),
                  Column(
                    children: [
                      _buildSummaryRow('Average Transaction', averageAmount),
                      _buildSummaryRow('Largest Expense', largestExpense),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return SproutCard(child: content);
      },
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
          text: format ? getFormattedCurrency(value) : "$value",
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
