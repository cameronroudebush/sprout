import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/selectable_accounts.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/finance_provider_logo.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:url_launcher/url_launcher.dart';

/// A dialog that allows selection of accounts from providers
class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  /// Currently selected provider for options
  ProviderConfig? _selectedProvider;

  /// A map of provider names to accounts available to add
  final Map<String, List<Account>> _accountsPerProvider = {};

  /// Selected accounts that we wish to add
  List<Account> _selectedAccounts = [];

  bool _gettingAccounts = false;
  String? _gettingAccountsError;
  bool _isAddingAccounts = false;

  Future<void> _setProvider(ProviderConfig providerConfig) async {
    setState(() {
      _selectedProvider = providerConfig;
    });
    // Grab all accounts for the given provider
    await _setAccountsForProvider(providerConfig);
  }

  /// Grabs all accounts for the given provider from the API and adds them to our internal map
  Future<void> _setAccountsForProvider(ProviderConfig providerConfig) async {
    setState(() {
      _gettingAccounts = true;
    });

    try {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      final accounts = (await accountProvider.api.accountControllerGetProviderAccounts(providerConfig.name))!;
      _accountsPerProvider[providerConfig.name] = accounts;
    } catch (e) {
      setState(() {
        _gettingAccountsError = "$e";
      });
    } finally {
      setState(() {
        _gettingAccounts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final accountsForProvider = _accountsPerProvider[_selectedProvider?.name];
    final accountsAvailable = accountsForProvider != null && accountsForProvider.isNotEmpty;

    Widget content;

    if (_gettingAccounts || _isAddingAccounts) {
      content = SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (_gettingAccountsError != null) {
      content = TextWidget(text: _gettingAccountsError!);
    } else if (_selectedProvider == null) {
      content = _getProvidersDisplay(context);
    } else {
      content = _getAccountsForProvider(context, _selectedProvider!);
    }

    return SproutDialogWidget(
      "Add Accounts",
      showCloseDialogButton: !_isAddingAccounts,
      closeButtonText: accountsAvailable ? "Close" : "Cancel",
      showSubmitButton: accountsAvailable && !_isAddingAccounts,
      allowSubmitClick: accountsAvailable && _selectedAccounts.isNotEmpty,
      onSubmitClick: () async {
        setState(() {
          _isAddingAccounts = true;
        });
        await accountProvider.api.accountControllerLinkProviderAccounts(_selectedProvider!.name, _selectedAccounts);
        await accountProvider.populateLinkedAccounts(true);
        // Close dialog
        Navigator.of(context).pop();
      },
      child: content,
    );
  }

  /// Displays the accounts for selection for the given provider
  Widget _getAccountsForProvider(BuildContext context, ProviderConfig providerConfig) {
    final accounts = _accountsPerProvider[providerConfig.name] ?? [];

    return Column(
      children: [
        Text(
          "Select the accounts you would like to add from ${providerConfig.name}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (accounts.isEmpty)
          Padding(
            padding: EdgeInsetsGeometry.only(left: 12, right: 12, top: 36, bottom: 12),
            child: Column(
              spacing: 24,
              children: [
                Text("No accounts available. You may need to link some from ${providerConfig.name}."),

                // Button to go directly to your endpoint to register new accounts
                if (providerConfig.accountFixUrl != null)
                  ButtonWidget(
                    text: "Go to ${providerConfig.name}",
                    onPressed: () async {
                      final Uri url = Uri.parse(providerConfig.accountFixUrl!);
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                      // Close dialog
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        // Render selectable accounts
        if (accounts.isNotEmpty)
          SelectableAccountsWidget(
            accounts: accounts,
            displaySubTypes: true,
            onSelectionChanged: (value) {
              setState(() {
                _selectedAccounts = value;
              });
            },
          ),
      ],
    );
  }

  /// Returns the display that allows us to select our provider type
  Widget _getProvidersDisplay(BuildContext context) {
    final configProvider = ServiceLocator.get<ConfigProvider>();
    final providers = configProvider.config?.providers;
    if (providers == null) {
      return Text(
        "No providers were configured properly.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );
    } else {
      return Column(
        spacing: 12,
        children: [
          Text(
            "Select the provider you would like to add the account from",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // Render the buttons
          Column(
            children: providers.map((provider) {
              // final accounts = entry.value; // If you need to use the accounts list for this provider
              return ButtonWidget(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                height: 60,
                text: provider.name,
                image: Expanded(
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsetsGeometry.all(12), child: FinanceProviderLogoWidget(provider)),
                    ],
                  ),
                ),
                child: Expanded(child: SizedBox(width: 1)),
                onPressed: () {
                  _setProvider(provider);
                },
              );
            }).toList(),
          ),
        ],
      );
    }
  }
}
