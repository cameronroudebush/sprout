import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/transaction/widgets/transaction_edit.dart';
import 'package:sprout/user/user_config_provider.dart';

// Renders a singular transaction with all necessary information in a single row
class TransactionRow extends ConsumerWidget {
  final Transaction transaction;

  const TransactionRow({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userConfig = ref.watch(userConfigProvider).value;
    final isPrivate = userConfig?.privateMode ?? false;

    return InkWell(
      onTap: () => showSproutPopup(context: context, builder: (_) => TransactionEdit(transaction)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          spacing: 16,
          children: [
            // Category
            CategoryIcon(transaction.category, avatarSize: 16),
            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(transaction.account.name, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
            // End content
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                if (transaction.pending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Pending",
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                Text(
                  transaction.amount.toCurrency(isPrivate),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: transaction.amount.toBalanceColor(theme),
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.disabledColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
