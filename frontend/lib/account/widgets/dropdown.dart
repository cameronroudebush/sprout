import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/state_tracker.dart';

/// A dropdown that allows account selection
class AccountDropdown extends StatefulWidget {
  final Account? account;
  final Function(Account? newValue) onChanged;
  final bool enabled;

  const AccountDropdown(this.account, this.onChanged, {super.key, this.enabled = true});

  @override
  State<AccountDropdown> createState() => _AccountDropdownState();
}

class _AccountDropdownState extends StateTracker<AccountDropdown> {
  @override
  Map<dynamic, DataRequest> get requests => {
    'accounts': DataRequest<AccountProvider, List<Account>>(
      provider: ServiceLocator.get<AccountProvider>(),
      onLoad: (p, force) => p.populateLinkedAccounts(),
      getFromProvider: (p) => p.linkedAccounts,
    ),
  };

  /// Returns the display for the given account
  Widget _getAccountDisplay(BuildContext context, ThemeData theme, Account account) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween, // This often fails in Dropdowns
      children: [
        Expanded(child: Text(account.name, overflow: TextOverflow.ellipsis, maxLines: 1)),
        const SizedBox(width: 8), // Add a little gap so text doesn't touch the balance
        Text(
          getFormattedCurrency(account.balance),
          style: TextStyle(
            color: getBalanceColor(account.balance, theme),
            fontWeight: FontWeight.bold, // Optional: makes balance stand out
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        // Find the matching account instance in the provider list to prevent reference errors
        Account? selectedValue;
        if (widget.account != null) {
          try {
            selectedValue = provider.linkedAccounts.firstWhere((a) => a.id == widget.account!.id);
          } catch (_) {
            selectedValue = null;
          }
        }

        return isLoading || provider.linkedAccounts.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
                    SizedBox(width: 12),
                    Text("Loading accounts"),
                  ],
                ),
              )
            : DropdownButtonFormField<Account>(
                isExpanded: true,
                menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                value: selectedValue,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                hint: const Text("Select an account"),
                selectedItemBuilder: (BuildContext context) {
                  return [
                    const Text("No Account"),
                    ...provider.linkedAccounts.map((account) {
                      return _getAccountDisplay(context, theme, account);
                    }),
                  ];
                },
                items: [
                  const DropdownMenuItem<Account>(value: null, child: Text("No Account")),
                  ...provider.linkedAccounts.map((account) {
                    return DropdownMenuItem<Account>(
                      value: account,
                      child: _getAccountDisplay(context, theme, account),
                    );
                  }),
                ],
                onChanged: !widget.enabled ? null : widget.onChanged,
              );
      },
    );
  }
}
