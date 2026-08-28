import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/provider/widgets/provider_display.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';

/// A dialog asking the user to re-sync a specific provider after updating/fixing a connection.
class ReSyncDialog extends ConsumerWidget {
  final ProviderTypeEnum providerType;

  const ReSyncDialog({
    super.key,
    required this.providerType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SproutBaseDialogWidget(
      'Re-Sync Account',
      showCloseDialogButton: true,
      closeButtonText: "Later",
      showSubmitButton: true,
      submitButtonText: "Sync Now",
      onSubmitClick: () async {
        Navigator.of(context).pop();
        await ref.read(accountsProvider.notifier).manualSync(
          providers: [providerType],
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back! Would you like to sync now to fetch your latest transactions and updated balances?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Target Provider:",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProviderDisplay(
                    providerType: providerType,
                    iconSize: 22,
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
