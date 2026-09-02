import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/account/widgets/selectable_account.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/shared/widgets/info_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable selector widget for standard providers that expose account previews
/// via a simple AsyncNotifier provider.
class ProviderGenericAccountSelector extends ConsumerWidget {
  final ProviderConfig provider;

  /// Accepts any Riverpod provider or family instance for invalidation and watching
  final ProviderOrFamily accountsProvider;
  final ValueChanged<List<Account>> onSelectionChanged;

  const ProviderGenericAccountSelector({
    super.key,
    required this.provider,
    required this.accountsProvider,
    required this.onSelectionChanged,
  });

  /// Generic helper to route linking requests via the provider API
  static Future<void> link(
    WidgetRef ref,
    List<Account> accounts,
    Future<void> Function(ProviderApi api, List<Account> accounts) linkCall,
  ) async {
    final api = ref.read(providerApiProvider).value;
    if (api == null) throw Exception("API not initialized");
    await linkCall(api, accounts);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider as ProviderListenable<AsyncValue<List<Account>?>>);

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
                onPressed: () => ref.invalidate(accountsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
            ],
          ),
        );
      },
      data: (accounts) {
        if (accounts == null || accounts.isEmpty) {
          return _buildEmptyState(theme);
        }
        return _buildAccountList(theme, accounts);
      },
    );
  }

  Widget _buildAccountList(ThemeData theme, List<Account> accounts) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsetsGeometry.only(bottom: 8),
            child: InfoCard(
              text: "Select accounts from ${provider.name} that you would like linked.",
            )),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SelectableAccountsWidget(
            accounts: accounts,
            displaySubTypes: true,
            showErrors: false,
            onSelectionChanged: onSelectionChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48, color: theme.disabledColor),
          Text("No accounts available from ${provider.name}."),
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
