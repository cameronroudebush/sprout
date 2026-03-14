import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/widgets/account_group.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A widget used to display given accounts with selection capability.
class SelectableAccountsWidget extends ConsumerStatefulWidget {
  final List<Account> accounts;
  final ValueChanged<List<Account>>? onSelectionChanged;
  final bool displaySubTypes;

  const SelectableAccountsWidget({
    super.key,
    required this.accounts,
    this.onSelectionChanged,
    this.displaySubTypes = false,
  });

  @override
  ConsumerState<SelectableAccountsWidget> createState() => _SelectableAccountsWidgetState();
}

class _SelectableAccountsWidgetState extends ConsumerState<SelectableAccountsWidget> {
  final Set<Account> _selectedAccounts = {};

  void _toggleSelection(Account account) {
    setState(() {
      if (_selectedAccounts.contains(account)) {
        _selectedAccounts.remove(account);
      } else {
        _selectedAccounts.add(account);
      }
    });
    widget.onSelectionChanged?.call(_selectedAccounts.toList());
  }

  @override
  Widget build(BuildContext context) {
    final config = AccountExtensions.groupConfig;
    final historyAsync = ref.watch(historicalAccountDataProvider);
    final selectedRange = ref.watch(userConfigProvider).value?.netWorthRange ?? ChartRangeEnum.oneDay;
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

    final groupedAccounts = config.keys.map((type) {
      final groupAccounts = widget.accounts.where((a) => a.type == type).toList();
      final ui = config[type];

      if (groupAccounts.isEmpty || ui == null) return const SizedBox.shrink();

      return AccountGroupSection(
        title: ui.title,
        accounts: groupAccounts,
        isPrivate: isPrivate,
        accentColor: ui.color,
        isNegative: ui.isNegative,
        initiallyExpanded: true,
        allowExpansion: false,
        selectedRange: selectedRange,
        historyList: historyAsync.value,
        renderAsCard: false, // Keeping it tight for the selection dialog
        onAccountClick: _toggleSelection,
        selectedAccounts: _selectedAccounts,
      );
    }).toList();

    return Column(mainAxisSize: MainAxisSize.min, children: groupedAccounts);
  }
}
