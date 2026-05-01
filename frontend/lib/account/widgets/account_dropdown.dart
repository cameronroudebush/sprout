import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/currency_provider.dart';

/// A dropdown that allows account selection using Riverpod for state management.
class AccountDropdown extends ConsumerWidget {
  final Account? account;
  final Function(Account? newValue) onChanged;
  final bool enabled;

  const AccountDropdown(this.account, this.onChanged, {super.key, this.enabled = true});

  /// Returns the display for the given account (Name + Formatted Balance)
  Widget _getAccountDisplay(WidgetRef ref, ThemeData theme, Account account, CurrencyFormatter formatter) {
    return Row(
      children: [
        Expanded(child: Text(account.name, overflow: TextOverflow.ellipsis, maxLines: 1)),
        const SizedBox(width: 8),
        Text(formatter.format(account.balance)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
            SizedBox(width: 12),
            Text("Loading accounts"),
          ],
        ),
      ),
      error: (err, stack) => const Center(child: Text("Error loading accounts")),
      data: (accountState) {
        final accounts = accountState.accounts;

        // Ensure we match the instance from the list to avoid Flutter's Dropdown equality errors
        final selectedValue = accounts.firstWhereOrNull((a) => a.id == account?.id);

        return DropdownButtonFormField<Account>(
          isExpanded: true,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
          dropdownColor: theme.colorScheme.surfaceContainerHighest,
          value: selectedValue,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: const Text("Select an account"),
          selectedItemBuilder: (BuildContext context) {
            return [
              const Text("No Account"),
              ...accounts.map((acc) => _getAccountDisplay(ref, theme, acc, formatter)),
            ];
          },
          items: [
            const DropdownMenuItem<Account>(value: null, child: Text("No Account")),
            ...accounts.map((acc) {
              return DropdownMenuItem<Account>(value: acc, child: _getAccountDisplay(ref, theme, acc, formatter));
            }),
          ],
          onChanged: !enabled ? null : onChanged,
        );
      },
    );
  }
}
