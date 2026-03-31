import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/selectable_account.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// This widget grabs the available accounts from SimpleFIN via the backend
///   and renders them for selection. Whatever you select and submit, you can then add to
///   your account for tracking.
class SimpleFinAccountSelector extends ConsumerWidget {
  final ProviderConfig provider;
  final ValueChanged<List<Account>> onSelectionChanged;

  const SimpleFinAccountSelector({
    super.key,
    required this.provider,
    required this.onSelectionChanged,
  });

  /// Given the accounts we wish to link, utilizes the endpoints to perform the link
  static Future<void> link(WidgetRef ref, List<Account> accounts) async {
    final api = ref.read(providerApiProvider).value;
    if (api == null) throw Exception("API not initialized");
    await api.simpleFinProviderControllerLinkAccounts(accounts);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(simpleFinAccountsProvider);

    return accountsAsync.when(
      loading: () => const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        final errorMessage = ref.read(notificationsProvider.notifier).parseOpenAPIException(error);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 40),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              FilledButton.icon(
                onPressed: () => ref.invalidate(simpleFinAccountsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
            ],
          ),
        );
      },
      data: (accounts) {
        if (accounts!.isEmpty) {
          return _buildEmptyState(theme);
        }
        return _buildAccountList(theme, accounts);
      },
    );
  }

  /// Builds the account selection
  Widget _buildAccountList(ThemeData theme, List<Account> accounts) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Text(
            "Select accounts from ${provider.name}",
            style: theme.textTheme.titleMedium,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SelectableAccountsWidget(
            accounts: accounts,
            displaySubTypes: true,
            onSelectionChanged: onSelectionChanged,
          ),
        ),
      ],
    );
  }

  /// Builds the state for when there are no accounts
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48, color: theme.disabledColor),
          const Text("No accounts available from this provider."),
          if (provider.accountFixUrl != null)
            FilledButton.icon(
              onPressed: () => _launchUrl(provider.accountFixUrl!),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text("Go to ${provider.name}"),
            ),
        ],
      ),
    );
  }

  /// Launches the app to add some accounts
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
