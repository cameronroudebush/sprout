import 'package:flutter/material.dart';
import 'package:sprout/model/account.dart'; // Assuming you have this model
import 'package:sprout/utils/formatters.dart';
import 'package:sprout/widgets/text.dart'; // Assuming you have this formatter

/// A widget used to display given accounts with selection capability
class AccountsWidget extends StatefulWidget {
  final List<Account> accounts;
  final ValueChanged<List<Account>>? onSelectionChanged;

  const AccountsWidget({
    super.key,
    required this.accounts,
    this.onSelectionChanged,
  });

  @override
  State<AccountsWidget> createState() => _AccountsWidgetState();
}

class _AccountsWidgetState extends State<AccountsWidget> {
  final Set<Account> _selectedAccounts = {};

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
    // Group accounts by type
    final Map<String, List<Account>> accountsByType = {};
    for (var account in widget.accounts) {
      accountsByType.putIfAbsent(account.type, () => []).add(account);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: accountsByType.entries.map((entry) {
          final String accountType = entry.key;
          final List<Account> accounts = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(),
                child: TextWidget(
                  referenceSize: 1.5,
                  text:
                      '${accountType[0].toUpperCase()}${accountType.substring(1)} Accounts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...accounts.map((account) {
                final isSelected = _selectedAccounts.contains(account);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 4.0,
                  ),
                  elevation: isSelected ? 6.0 : 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: isSelected
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2.5,
                          ) // Themed border
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    // Use InkWell for better tap visual feedback
                    onTap: widget.onSelectionChanged == null
                        ? null
                        : () => _toggleSelection(account),
                    borderRadius: BorderRadius.circular(15.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(account.icon, size: 30.0),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  referenceSize: 1.05,
                                  text: account.name,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  account
                                      .institution
                                      .name, // Display institution name
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextWidget(
                                referenceSize: 1.05,
                                text: currencyFormatter.format(account.balance),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: account.balance >= 0
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                              ),
                              if (account.institution.hasError)
                                GestureDetector(
                                  onTap:
                                      () {}, // Required for tooltip to work on tap
                                  child: Tooltip(
                                    message:
                                        'There was an error syncing with ${account.institution.name}. This may need updated in your provider.',
                                    child: const Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Icon(
                                        Icons.warning,
                                        color: Colors.red,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    size: 24.0,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (accountsByType.keys.last !=
                  accountType) // Add a divider if it's not the last type
                const Divider(
                  height: 30,
                  thickness: 1.5,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
