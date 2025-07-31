import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/selectable_accounts.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';

/// A dialog that allows selection of accounts from providers
class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  List<Account> _accounts = [];
  List<Account> _selectedAccounts = [];
  bool _gettingAccounts = false;
  String? _gettingAccountsError;
  bool _isAddingAccounts = false;

  @override
  void initState() {
    super.initState();
    setAccounts();
  }

  Future<void> setAccounts() async {
    setState(() {
      _gettingAccounts = true;
    });
    try {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      final accounts = await accountProvider.api.getProviderAccounts();
      setState(() {
        _accounts = accounts;
      });
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
    AccountProvider accountProvider = Provider.of<AccountProvider>(context, listen: false);
    return AlertDialog(
      title: Center(child: TextWidget(referenceSize: 2, text: 'Select Accounts to Add')),
      content: _accounts.isEmpty
          ? _gettingAccounts || _isAddingAccounts
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Center(
                      child: TextWidget(
                        referenceSize: 1,
                        text:
                            _gettingAccountsError ??
                            'No accounts found. Did you add them in the provider? Or have you already added them all?',
                      ),
                    ),
                  )
          : SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // Set a fixed width
              height: MediaQuery.of(context).size.height * 0.6, // Set a fixed height
              child: SelectableAccountsWidget(
                accounts: _accounts,
                onSelectionChanged: (value) {
                  setState(() {
                    _selectedAccounts = value;
                  });
                },
              ),
            ),
      actions: <Widget>[
        if (_accounts.isEmpty)
          Center(
            child: ButtonWidget(
              text: "Close",
              minSize: MediaQuery.of(context).size.width * .4,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        else ...[
          ButtonWidget(
            text: "Cancel",
            minSize: MediaQuery.of(context).size.width * .4,
            color: Theme.of(context).colorScheme.onError,
            onPressed: _isAddingAccounts
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
          ),
          ButtonWidget(
            text: "Add selected",
            minSize: MediaQuery.of(context).size.width * .4,
            onPressed: _isAddingAccounts
                ? null
                : _selectedAccounts.isEmpty
                ? null
                : () async {
                    setState(() {
                      _isAddingAccounts = true;
                    });
                    await accountProvider.api.linkProviderAccounts(_selectedAccounts);
                    await Provider.of<AccountProvider>(context, listen: false).populateLinkedAccounts();
                    // Close dialog
                    Navigator.of(context).pop();
                  },
          ),
        ],
      ],
    );
  }
}
