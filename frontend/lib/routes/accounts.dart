import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/dialog/add_account_dialog.dart';
import 'package:sprout/account/widgets/account_details.dart';
import 'package:sprout/account/widgets/accounts_summary.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';
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
        Widget body;
        // Determine the body content based on URL parameters
        if (accountId != null) {
          final account = state.accounts.firstWhere((a) => a.id == accountId, orElse: () => state.accounts.first);
          body = AccountDetailsView(account: account, isPrivate: isPrivate);
        } else {
          body = AccountSummaryView(accounts: state.accounts, isPrivate: isPrivate);
        }

        return Scaffold(
          body: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 8), child: body),
          // Add a FAB button
          floatingActionButton: accountId != null
              ? null
              : SproutSpeedDial(
                  actions: [
                    FABAction(
                      icon: Icons.add,
                      label: 'Add Account',
                      onTap: (context) => showSproutPopup(context: context, builder: (_) => const AddAccountDialog()),
                    ),
                    FABAction(
                      icon: Icons.refresh,
                      label: 'Sync All',
                      onTap: (context) => showSproutPopup(
                        context: context,
                        builder: (context) => SproutBaseDialogWidget(
                          "Confirm Sync",
                          showCloseDialogButton: true,
                          closeButtonText: "Cancel",
                          showSubmitButton: true,
                          submitButtonText: "Start Sync",
                          onSubmitClick: () {
                            // Trigger the sync
                            ref.read(accountsProvider.notifier).manualSync();
                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Are you sure you want to manually sync all accounts? This may take a moment depending on your providers.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
