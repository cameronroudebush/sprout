import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/dialog/edit_dialog.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/transaction/models/extensions/transaction_extensions.dart';
import 'package:sprout/transaction/widgets/website_icon.dart';

class TransactionHeroCard extends ConsumerWidget {
  final Transaction transaction;
  final String description;
  final ValueChanged<String> onDescriptionChanged;

  const TransactionHeroCard({
    super.key,
    required this.transaction,
    required this.description,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final websiteUrl = transaction.extra?.website;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (websiteUrl != null && websiteUrl.isNotEmpty) ...[
                        WebsiteIconWidget(websiteUrl: websiteUrl, size: 24),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          description,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: transaction.pending
                            ? null
                            : () => showSproutEditDialog(
                                  context: context,
                                  title: "Edit Description",
                                  label: "Description",
                                  currentValue: description,
                                  icon: Icons.edit_note,
                                  onSave: (newDesc) async {
                                    onDescriptionChanged(newDesc);
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _getStatusBadge(theme, transaction.pending),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  transaction.relativeTime,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  formatter.format(transaction.amount),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: transaction.amount < 0 ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusBadge(ThemeData theme, bool isPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? theme.colorScheme.errorContainer : theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        (isPending ? "Pending" : "Posted").toTitleCase,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isPending ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
