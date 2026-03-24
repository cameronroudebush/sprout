import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/selectable_account.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/widgets/provider_logo.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// This dialog provides the ability to select a provider to add an account from and gives that as an ability
class AddAccountDialog extends ConsumerStatefulWidget {
  const AddAccountDialog({super.key});

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  ProviderConfig? _selectedProvider;
  final Map<String, List<Account>> _accountsPerProvider = {};
  List<Account> _selectedAccounts = [];

  bool _gettingAccounts = false;
  String? _gettingAccountsError;
  bool _isAddingAccounts = false;

  /// Updates the selected provider and fetches accounts using Riverpod
  Future<void> _setProvider(ProviderConfig providerConfig) async {
    setState(() {
      _selectedProvider = providerConfig;
      _gettingAccounts = true;
      _gettingAccountsError = null;
    });

    try {
      // Access the API via the accountProvider notifier
      final api = ref.read(accountApiProvider).value;
      final response = await api?.accountControllerGetProviderAccounts(providerConfig.name);

      if (response != null) {
        setState(() {
          _accountsPerProvider[providerConfig.name] = response;
        });
      }
    } catch (e) {
      setState(() => _gettingAccountsError = ref.read(notificationsProvider.notifier).parseOpenAPIException(e));
    } finally {
      setState(() => _gettingAccounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch the configuration provider for the list of available providers
    final config = ref.watch(secureConfigProvider).value;
    final accountsForProvider = _accountsPerProvider[_selectedProvider?.name];
    final accountsAvailable = accountsForProvider?.isNotEmpty ?? false;

    Widget content;
    if (_gettingAccounts || _isAddingAccounts) {
      content = const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    } else if (_gettingAccountsError != null) {
      content = Text(_gettingAccountsError!, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge);
    } else if (_selectedProvider == null) {
      content = _getProvidersDisplay(theme, context, config?.providers ?? []);
    } else {
      content = _getAccountsForProvider(theme, context, _selectedProvider!);
    }

    return SproutBaseDialogWidget(
      "Add Accounts",
      showCloseDialogButton: !_isAddingAccounts,
      closeButtonText: accountsAvailable || _gettingAccountsError != null ? "Close" : "Cancel",
      showSubmitButton: accountsAvailable && !_isAddingAccounts,
      allowSubmitClick: accountsAvailable && _selectedAccounts.isNotEmpty,
      onSubmitClick: () async {
        setState(() => _isAddingAccounts = true);

        final notifier = ref.read(accountApiProvider).value;
        await notifier?.accountControllerLinkProviderAccounts(_selectedProvider!.name, _selectedAccounts);

        if (mounted) Navigator.of(context).pop();
      },
      child: content,
    );
  }

  Widget _getAccountsForProvider(ThemeData theme, BuildContext context, ProviderConfig providerConfig) {
    final accounts = _accountsPerProvider[providerConfig.name] ?? [];

    return Column(
      children: [
        if (accounts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Select accounts from ${providerConfig.name}",
              style: theme.textTheme.bodyLarge,
            ),
          ),
        if (accounts.isEmpty) _buildEmptyState(providerConfig),
        if (accounts.isNotEmpty)
          SizedBox(
              width: 500,
              child: SelectableAccountsWidget(
                accounts: accounts,
                displaySubTypes: true,
                onSelectionChanged: (value) => setState(() => _selectedAccounts = value),
              )),
      ],
    );
  }

  Widget _buildEmptyState(ProviderConfig providerConfig) {
    return Column(
      spacing: 24,
      children: [
        Text("No accounts available from ${providerConfig.name}."),
        if (providerConfig.accountFixUrl != null)
          FilledButton(
            onPressed: () => _launchUrl(providerConfig.accountFixUrl!),
            child: Text("Go to ${providerConfig.name}"),
          ),
      ],
    );
  }

  Widget _getProvidersDisplay(ThemeData theme, BuildContext context, List<ProviderConfig> providers) {
    if (providers.isEmpty) {
      return Text("No providers configured.", style: theme.textTheme.bodyLarge);
    }

    return Column(
      spacing: 12,
      children: [
        Text("Select a provider", style: theme.textTheme.bodyLarge),
        ...providers.map(
          (provider) => FilledButton(
              onPressed: () => _setProvider(provider),
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [FinanceProviderLogoWidget(provider), Text(provider.name), const SizedBox.shrink()],
              )),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
