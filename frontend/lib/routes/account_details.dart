import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_details.dart';
import 'package:sprout/account/widgets/account_merge_dialog.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';
import 'package:sprout/shared/widgets/tab_selector.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page specific to display account details
class AccountDetailsPage extends ConsumerWidget {
  final String? accountId;

  const AccountDetailsPage({super.key, this.accountId});

  void _showCleanDuplicatesDialog(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    showSproutPopup(
      context: context,
      builder: (dialogContext) => SproutBaseDialogWidget(
        'Clean Duplicates',
        showCloseDialogButton: true,
        closeButtonStyle: ThemeHelpers.primaryButton,
        showSubmitButton: true,
        submitButtonText: 'Remove Duplicates',
        submitButtonStyle: ThemeHelpers.errorButton,
        onSubmitClick: () async {
          Navigator.of(dialogContext).pop();
          final notifications = ref.read(notificationsProvider.notifier);
          try {
            final api = await ref.read(transactionApiProvider.future);
            await api.transactionControllerRemoveDuplicates(
              accountId: account.id,
            );
          } catch (e) {
            notifications.openWithAPIException(e);
          }
        },
        child: Text(
          'This will scan ${account.name} for duplicate transactions (those sharing the exact same date and amount) and permanently delete the duplicates.\n\nThis action cannot be undone.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    showSproutPopup(
      context: context,
      builder: (dialogContext) => SproutBaseDialogWidget(
        'Delete Account',
        showCloseDialogButton: true,
        closeButtonStyle: ThemeHelpers.primaryButton,
        showSubmitButton: true,
        submitButtonText: 'Delete',
        submitButtonStyle: ThemeHelpers.errorButton,
        onSubmitClick: () async {
          Navigator.of(dialogContext).pop();
          NavigationProvider.back(context, ref);
          await NavigationProvider.redirect('/accounts');
          await ref.read(accountsProvider.notifier).delete(account.id);
        },
        child: Text(
          'Removing ${account.name} will remove all transactions and history linked to this account. This cannot be undone!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      data: (state) {
        final account = state.accounts.firstWhereOrNull(
          (a) => a.id == accountId,
        );

        if (account == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) NavigationProvider.redirect('/accounts');
          });

          return const SizedBox.shrink();
        }

        final zpid = account.provider == ProviderTypeEnum.zillow
            ? ref.watch(zillowInfoProvider(account.id)).value
            : null;

        return Scaffold(
          body: AccountDetailsView(account: account),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.sizeOf(context).width <
                      SproutLayoutBuilder.desktopBreakpoint
                  ? SproutTabbedLayout.mobileNavigationScrollInset
                  : 0,
            ),
            child: SproutSpeedDial(
              actions: [
                FABAction(
                  icon: Icons.merge,
                  label: 'Merge Accounts',
                  onTap: (context) => showSproutPopup(
                    context: context,
                    builder: (_) => AccountMergeDialog(account),
                  ),
                ),
                FABAction(
                  icon: Icons.delete_sweep,
                  label: 'Clean Duplicate Transactions',
                  onTap: (context) =>
                      _showCleanDuplicatesDialog(context, ref, account),
                ),
                if (zpid != null)
                  FABAction(
                    icon: Icons.house,
                    label: 'View on Zillow',
                    onTap: (_) async {
                      final url = Uri.parse(
                        'https://www.zillow.com/homes/${zpid}_zpid/',
                      );
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                FABAction(
                  icon: Icons.delete,
                  label: 'Delete Account',
                  onTap: (context) => _showDeleteDialog(context, ref, account),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}
