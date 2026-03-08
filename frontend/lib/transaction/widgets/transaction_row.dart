import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/transaction/models/extensions/transaction_extensions.dart';

/// Renders the given transaction as a row
class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final bool isPrivate;

  const TransactionRow({super.key, required this.transaction, required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = (transaction.amount) > 0;

    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          spacing: 12,
          children: [
            CategoryIcon(transaction.category),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.description,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    transaction.timeText,
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              transaction.amount.toCurrency(isPrivate),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens a dialog to show the details of this transaction
  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SproutBaseDialogWidget(
        "Transaction Details",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(transaction.amount.toCurrency(isPrivate)),
          ],
        ),
      ),
    );
  }
}
