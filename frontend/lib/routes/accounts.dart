import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_details.dart';
import 'package:sprout/account/widgets/accounts_summary.dart';
import 'package:sprout/user/user_config_provider.dart';

/// The primary entry point for the Accounts section of Sprout.
///
/// This widget reactively switches between a grouped list of all accounts
/// and a detailed view of a single account based on the 'id' query parameter
/// present in the current URI.
class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Automatically extract the account ID from the GoRouter state
    final String? accountId = GoRouterState.of(context).uri.queryParameters['id'];

    final accountsAsync = ref.watch(accountsProvider);
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

    return accountsAsync.when(
      data: (state) {
        if (accountId != null) {
          final account = state.accounts.firstWhere((a) => a.id == accountId, orElse: () => state.accounts.first);
          return AccountDetailsView(account: account, isPrivate: isPrivate);
        }
        return AccountSummaryView(accounts: state.accounts, isPrivate: isPrivate);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
