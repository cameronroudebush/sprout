import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/provider/widgets/provider_display.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';

/// A dialog that allows for manual account syncing. Allows selection of what providers to sync.
class AccountSyncDialog extends ConsumerStatefulWidget {
  const AccountSyncDialog({super.key});

  @override
  ConsumerState<AccountSyncDialog> createState() => _AccountSyncDialogState();
}

class _AccountSyncDialogState extends ConsumerState<AccountSyncDialog> {
  bool _isAllSelected = false;
  final Set<ProviderTypeEnum> _selectedProviders = {};

  void _toggleAll(bool selected, List<ProviderTypeEnum> activeProviders) {
    setState(() {
      _isAllSelected = selected;
      if (selected) {
        _selectedProviders.addAll(activeProviders);
      } else {
        _selectedProviders.clear();
      }
    });
  }

  void _toggleProvider(ProviderTypeEnum provider, bool selected, int totalActive) {
    setState(() {
      if (selected) {
        _selectedProviders.add(provider);
      } else {
        _selectedProviders.remove(provider);
      }
      _isAllSelected = _selectedProviders.length == totalActive;
    });
  }

  void _onStartSync() {
    // Send the explicit list of selected providers, cannot use null to trigger "all" since a user might not use every provider
    ref.read(accountsProvider.notifier).manualSync(
          providers: _selectedProviders.toList(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider).value?.accounts ?? [];

    // Filter down to a unique list of providers currently in use
    final activeProviders = accounts.map((account) => account.provider).toSet().toList();

    // Handle case where user has no accounts to sync
    if (activeProviders.isEmpty) {
      return SproutBaseDialogWidget(
        "Manual Sync",
        showCloseDialogButton: true,
        closeButtonText: "Close",
        showSubmitButton: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
          child: Center(
            child: Text(
              "You have no connected accounts available to sync.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SproutBaseDialogWidget(
      "Manual Sync",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      submitButtonText: "Start Sync",
      onSubmitClick: _selectedProviders.isEmpty ? null : _onStartSync,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational header card
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                spacing: 10,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  Expanded(
                    child: Text(
                      "This requests the latest transaction and balance updates directly from your connected financial institutions right now, instead of waiting for the next sync cycle. Select what providers you would like to sync below.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top-level "All Providers" selection
            InkWell(
              onTap: () => _toggleAll(!_isAllSelected, activeProviders),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isAllSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isAllSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2),
                    width: _isAllSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(
                      _isAllSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: _isAllSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      "All Providers",
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isAllSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Provider grid filtered by active accounts
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 110,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                mainAxisExtent: 80,
              ),
              itemCount: activeProviders.length,
              itemBuilder: (context, index) {
                final provider = activeProviders[index];
                final isSelected = _selectedProviders.contains(provider);

                return InkWell(
                  onTap: () => _toggleProvider(provider, !isSelected, activeProviders.length),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer.withOpacity(0.6)
                          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            size: 14,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                          ),
                        ),
                        Center(
                          child: ProviderDisplay(
                            providerType: provider,
                            direction: ProviderDisplayDirection.vertical,
                            iconSize: 36,
                            spacing: 4,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
