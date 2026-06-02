import 'package:flutter/material.dart';
import 'package:sprout/routes/util/navigation_provider.dart';

/// A widget used to display a message for when there are not accounts
class AccountsEmptyWidget extends StatelessWidget {
  final bool showRedirect;

  const AccountsEmptyWidget({
    super.key,
    required this.showRedirect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            Text(
              "No accounts found",
              style: theme.textTheme.titleLarge,
            ),
            Text(
              showRedirect
                  ? "You haven't added any accounts yet. Head over to the accounts page to get started."
                  : "Use the floating action button in the bottom right to add a new account!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (showRedirect)
              FilledButton.icon(
                onPressed: () => NavigationProvider.redirect('accounts'),
                icon: const Icon(Icons.add),
                label: const Text("Add Account"),
              ),
          ],
        ),
      ),
    );
  }
}
