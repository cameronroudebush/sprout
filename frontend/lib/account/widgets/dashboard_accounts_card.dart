import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/accounts_summary.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A widget that provides a high-level overview of all accounts for the dashboard.
/// Reuses the shared summary and row components for a consistent 2026 UI.
class DashboardAccountsCard extends ConsumerWidget {
  const DashboardAccountsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

    return accountsAsync.when(
      data: (state) => AccountSummaryView(
        accounts: state.accounts,
        isPrivate: isPrivate,
        individualCards: false,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
