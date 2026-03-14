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
      child: Container(
        decoration: BoxDecoration(
          color: transaction.pending ? theme.colorScheme.secondary.withValues(alpha: 0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          spacing: 12,
          children: [
            CategoryIcon(transaction.category),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 6,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (transaction.pending) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "PENDING",
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Account name
                  Text(
                    transaction.account.name,
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Amount and Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.amount.toCurrency(isPrivate),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  transaction.timeText,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Opens a dialog to show the details of this transaction
  void _showDetails(BuildContext context) {
    // TODO: Separate dialog, for editing too
    showSproutPopup(
      context: context,
      builder: (context) => SproutBaseDialogWidget(
        "Transaction Details",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _buildDetailField("Description", transaction.description, isBold: true),
            _buildDetailField("Account", transaction.account.name),
            _buildDetailField("Amount", transaction.amount.toCurrency(isPrivate)),
            _buildDetailField("Date", transaction.timeText),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value, {bool isBold = false}) {
    // TODO: Remove with new dialog
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
