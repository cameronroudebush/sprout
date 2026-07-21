import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_total_summary_card.dart';
import 'package:sprout/account/widgets/accounts_empty.dart';
import 'package:sprout/account/widgets/accounts_summary.dart';
import 'package:sprout/provider/widgets/dialog/provider.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';

/// The primary entry point for the Accounts section of Sprout.
class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  void _showSyncPopup(BuildContext context, WidgetRef ref) {
    showSproutPopup(
      context: context,
      builder: (context) => SproutBaseDialogWidget(
        "Confirm Sync",
        showCloseDialogButton: true,
        closeButtonText: "Cancel",
        showSubmitButton: true,
        submitButtonText: "Start Sync",
        onSubmitClick: () {
          ref.read(accountsProvider.notifier).manualSync();
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.whenDefault(
      data: (state) {
        return Scaffold(
          body: state.accounts.isEmpty
              ? const AccountsEmptyWidget(showRedirect: false)
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SproutRouteWrapper(
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SproutCard(
                                child: Padding(
                                    padding: const EdgeInsets.all(12), child: TotalSummary(accounts: state.accounts))),
                            AccountSummaryView(
                              accounts: state.accounts,
                              collapsible: false,
                            ),
                          ],
                        )),
                  ),
                ),
          floatingActionButton: SproutSpeedDial(
            actions: [
              FABAction(
                icon: Icons.add,
                label: 'Add Account',
                onTap: (context) => showSproutPopup(context: context, builder: (_) => const ProviderDialog()),
              ),
              FABAction(icon: Icons.refresh, label: 'Sync All', onTap: (context) => _showSyncPopup(context, ref)),
            ],
          ),
        );
      },
    );
  }
}
