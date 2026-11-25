import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/currency_provider.dart';

/// A dropdown that allows account selection using Riverpod for state management.
class AccountDropdown extends ConsumerWidget {
  final String? accountId;
  final Function(Account? newValue) onChanged;
  final bool enabled;
  final List<Account>? accounts;
  final bool allowNoAccount;
  final InputDecoration? decoration;
  final String? Function(Account?)? validator;

  const AccountDropdown(this.accountId, this.onChanged,
      {super.key,
      this.enabled = true,
      this.accounts,
      this.allowNoAccount = true,
      this.decoration,
      this.validator});

  /// Returns account icon, name, institution, and formatted balance.
  Widget _getAccountDisplay(
      ThemeData theme, Account account, CurrencyFormatter formatter,
      {bool selected = false}) {
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(account.name, overflow: TextOverflow.ellipsis, maxLines: 1),
        Text(account.institution.name,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
      ],
    );

    return Row(
      spacing: 8,
      children: [
        AccountIcon(account, size: 24),
        Expanded(
          child: Transform.translate(
            offset: Offset(0, selected ? -8 : 0),
            child: selected
                ? LayoutBuilder(
                    builder: (context, constraints) => OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: constraints.maxWidth,
                      maxWidth: constraints.maxWidth,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: text,
                    ),
                  )
                : text,
          ),
        ),
        Text(formatter.format(account.balance)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);

    if (accounts != null) {
      return _buildDropdown(context, theme, accounts!, formatter);
    }

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
      error: (err, stack) =>
          const Center(child: Text("Error loading accounts")),
      data: (accountState) =>
          _buildDropdown(context, theme, accountState.accounts, formatter),
    );
  }

  Widget _buildDropdown(BuildContext context, ThemeData theme,
      List<Account> accounts, CurrencyFormatter formatter) {
    // Ensure we match the instance from the list to avoid Flutter's Dropdown equality errors
    final selectedValue = accounts.firstWhereOrNull((a) => a.id == accountId);
    final items = [
      if (allowNoAccount)
        const DropdownMenuItem<Account>(value: null, child: Text("No Account")),
      ...accounts.map((account) => DropdownMenuItem<Account>(
            value: account,
            child: _getAccountDisplay(theme, account, formatter),
          )),
    ];

    return DropdownButtonFormField<Account>(
      isExpanded: true,
      itemHeight: null,
      menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
      dropdownColor: theme.colorScheme.surfaceContainerHighest,
      initialValue: selectedValue,
      decoration: decoration ??
          const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
      hint: const Text("Select an account"),
      validator: validator,
      selectedItemBuilder: (BuildContext context) => [
        if (allowNoAccount) const Text("No Account"),
        ...accounts.map((account) =>
            _getAccountDisplay(theme, account, formatter, selected: true)),
      ],
      items: items,
      onChanged: !enabled ? null : onChanged,
    );
  }
}
