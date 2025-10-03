import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/widgets/category_icon.dart';
import 'package:sprout/transaction/widgets/transaction_info.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A widget that displays a transaction row on a transaction table
class TransactionRow extends StatelessWidget {
  static double rowHeight = 66;

  final Transaction? transaction;
  final bool isEvenRow;
  final bool renderPostedTime;

  /// If we're allowed to open this dialog menu
  final bool allowDialog;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.isEvenRow,
    this.renderPostedTime = true,
    this.allowDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? rowColor;
    if (transaction!.pending) {
      rowColor = Colors.grey.withValues(alpha: 0.2);
    } else if (isEvenRow) {
      rowColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2);
    }
    if (transaction == null) return Center(child: CircularProgressIndicator());

    final timeText = DateTime.now().difference(transaction!.posted).inDays > 3
        ? transaction!.posted.toShort
        : timeago.format(transaction!.posted);

    return InkWell(
      onTap: allowDialog
          ? () {
              showDialog(context: context, builder: (_) => TransactionInfo(transaction!));
            }
          : null,
      child: Container(
        color: rowColor,
        width: double.infinity,
        height: TransactionRow.rowHeight,
        padding: EdgeInsetsGeometry.all(6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Render an type icon
                  CategoryIcon(transaction?.category),
                  // Description info
                  Flexible(
                    child: Column(
                      spacing: 6,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        TextWidget(
                          referenceSize: 1.15,
                          text: transaction!.description,
                          style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                        ),
                        // Account
                        TextWidget(
                          referenceSize: 0.9,
                          text: transaction!.account.name.toTitleCase,
                          style: TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  transaction!.pending
                      ? SproutTooltip(
                          message: "This transaction has not yet posted",
                          child: Icon(Icons.hourglass_empty, size: 24, color: theme.colorScheme.onSurfaceVariant),
                        )
                      : SizedBox.shrink(),
                  Column(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Amount
                      TextWidget(
                        text: getFormattedCurrency(transaction!.amount),
                        style: TextStyle(color: getBalanceColor(transaction!.amount, theme)),
                        textAlign: TextAlign.end,
                      ),
                      // Time
                      if (renderPostedTime)
                        Row(
                          spacing: 4,
                          children: [
                            TextWidget(
                              referenceSize: .9,
                              text: timeText,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Icon(Icons.calendar_month, color: Colors.grey),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
