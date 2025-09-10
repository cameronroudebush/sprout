import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A widget that displays a transaction row on a transaction table
class TransactionRow extends StatelessWidget {
  final Transaction? transaction;
  final bool isEvenRow;
  final bool renderPostedTime;

  const TransactionRow({super.key, required this.transaction, required this.isEvenRow, this.renderPostedTime = true});

  IconData _getIconForCategory(String? category) {
    if (category == null) {
      return Icons.category;
    }

    final lowerCaseCategory = category.toLowerCase();

    switch (lowerCaseCategory) {
      case 'food & drink':
        return Icons.fastfood;
      case 'travel':
        return Icons.flight;
      case 'service':
        return Icons.room_service;
      case 'recreation':
        return Icons.sports_baseball;
      case 'shops':
        return Icons.shopping_bag;
      case 'unauthorized':
        return Icons.warning;
      case 'loan':
        return Icons.money;
      case 'interest':
        return Icons.money_off;
      case 'payment':
        return Icons.payment;
      case 'retirement':
        return Icons.elderly;
      case 'investments':
        return Icons.trending_up;
      case 'healthcare':
        return Icons.local_hospital;
      case 'subscriptions':
        return Icons.subscriptions;
      case 'online shopping':
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
  }

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

    final avatarSize = 20.0;
    final timeText = DateTime.now().difference(transaction!.posted).inDays > 3
        ? formatDate(transaction!.posted, includeTime: true)
        : timeago.format(transaction!.posted);

    return Container(
      color: rowColor,
      width: double.infinity,
      height: 66,
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
                CircleAvatar(radius: avatarSize, child: Icon(_getIconForCategory(transaction!.category))),
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
    );
  }
}
