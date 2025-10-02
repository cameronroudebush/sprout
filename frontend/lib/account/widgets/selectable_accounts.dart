import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/models/account.dart'; // Assuming you have this model
import 'package:sprout/account/widgets/account_groups.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/widgets/scroll.dart';

/// A widget used to display given accounts with selection capability
class SelectableAccountsWidget extends StatefulWidget {
  final List<Account> accounts;
  final ValueChanged<List<Account>>? onSelectionChanged;

  /// If we should display the selectable subType of the account
  final bool displaySubTypes;

  const SelectableAccountsWidget({
    super.key,
    required this.accounts,
    this.onSelectionChanged,
    this.displaySubTypes = false,
  });

  @override
  State<SelectableAccountsWidget> createState() => _SelectableAccountsWidgetState();
}

class _SelectableAccountsWidgetState extends State<SelectableAccountsWidget> {
  final Set<Account> _selectedAccounts = {};

  /// Toggles the selection for the current account
  void _toggleSelection(Account account) {
    if (widget.onSelectionChanged != null) {
      setState(() {
        if (_selectedAccounts.contains(account)) {
          _selectedAccounts.remove(account);
        } else {
          _selectedAccounts.add(account);
        }
      });
      widget.onSelectionChanged!(_selectedAccounts.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        return SproutScrollView(
          padding: const EdgeInsets.all(8.0),
          child: AccountGroupsWidget(
            netWorthPeriod: ChartRange.sevenDays,
            accounts: widget.accounts,
            onAccountClick: _toggleSelection,
            displayStats: false,
            selectedAccounts: _selectedAccounts,
            allowCollapse: false,
            applyCard: true,
            displaySubTypes: widget.displaySubTypes,
          ),
        );
      },
    );
  }
}
