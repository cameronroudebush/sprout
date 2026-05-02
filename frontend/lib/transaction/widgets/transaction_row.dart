import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/transaction/widgets/transaction_edit.dart';

// Renders a singular transaction with all necessary information in a single row
class TransactionRow extends ConsumerWidget {
  final Transaction transaction;

  /// If we should be allowed to click this row to open the dialog
  final bool allowDialog;

  const TransactionRow(this.transaction, {super.key, this.allowDialog = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);

    final cat = ref.watch(
      categoriesProvider.select((asyncState) {
        return asyncState.value?.firstWhereOrNull(
          (a) => a.id == transaction.categoryId,
        );
      }),
    );

    final account = ref.watch(
      accountsProvider.select((asyncState) {
        return asyncState.value?.accounts.firstWhereOrNull(
          (a) => a.id == transaction.accountId,
        );
      }),
    );

    return InkWell(
      onTap:
          !allowDialog ? null : () => showSproutPopup(context: context, builder: (_) => TransactionEdit(transaction)),
      child: Container(
        decoration: BoxDecoration(
          color: transaction.pending ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            spacing: 16,
            children: [
              // Category
              CategoryIcon(cat, avatarSize: 16),
              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      account?.name ?? "Unknown",
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // End content
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    formatter.format(transaction.amount),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: transaction.amount.toBalanceColor(theme),
                    ),
                  ),
                  if (allowDialog) Icon(Icons.chevron_right, color: theme.disabledColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
