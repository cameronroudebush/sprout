import 'package:flutter/material.dart';
import 'package:sprout/model/account.dart'; // Assuming you have this model
import 'package:sprout/utils/formatters.dart'; // Assuming you have this formatter

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
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ...widget.accounts.map((account) {
            final isSelected = _selectedAccounts.contains(account);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: isSelected
                  ? 4.0
                  : 2.0, // Slightly more elevation for selected
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: isSelected
                    ? const BorderSide(color: Colors.blueAccent, width: 2.0)
                    : BorderSide.none, // Blue border for selected
              ),
              child: ListTile(
                leading: Icon(account.icon, color: Colors.blueGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                title: Text(
                  account.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyFormatter.format(account.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: account.balance >= 0
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                    if (account.institution.hasError)
                      Tooltip(
                        message:
                            'There was an error syncing with ${account.institution.name}. This may need updated in your provider.',
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.warning, color: Colors.red),
                        ),
                      ),
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.check_circle, color: Colors.blue),
                      ),
                  ],
                ),
                onTap: widget.onSelectionChanged == null
                    ? null
                    : () => _toggleSelection(account),
              ),
            );
          }),
        ],
      ),
    );
  }
}
