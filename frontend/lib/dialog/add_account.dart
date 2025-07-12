import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/account.dart';
import 'package:sprout/model/account.dart';
import 'package:sprout/widgets/accounts.dart';
import 'package:sprout/widgets/button.dart';
import 'package:sprout/widgets/text.dart';

class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

/// A dialog that display an add account capability
class _AddAccountDialogState extends State<AddAccountDialog> {
  List<Account> _accounts = [];
  List<Account> _selectedAccounts = [];
  bool _gettingAccounts = false;

  @override
  void initState() {
    super.initState();
    setAccounts();
  }

  Future<void> setAccounts() async {
    setState(() {
      _gettingAccounts = true;
    });
    final accountAPI = Provider.of<AccountAPI>(context, listen: false);
    final accounts = await accountAPI.getProviderAccounts() as List<Account>;
    setState(() {
      _gettingAccounts = false;
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    AccountAPI accountAPI = Provider.of<AccountAPI>(context, listen: false);
    return AlertDialog(
      title: Center(
        child: TextWidget(referenceSize: 2, text: 'Select Accounts to Add'),
      ),
      content: _accounts.isEmpty
          ? _gettingAccounts
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: const Center(
                      child: TextWidget(
                        referenceSize: 1,
                        text:
                            'No accounts found. Did you add them in the provider?',
                      ),
                    ),
                  )
          : SizedBox(
              width:
                  MediaQuery.of(context).size.width * 0.8, // Set a fixed width
              height:
                  MediaQuery.of(context).size.height *
                  0.6, // Set a fixed height
              child: AccountsWidget(
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ButtonWidget(
            text: "Add selected",
            minSize: MediaQuery.of(context).size.width * .4,
            onPressed: _selectedAccounts.isEmpty
                ? null
                : () async {
                    await accountAPI.linkProviderAccounts(_selectedAccounts);
                    accountAPI.accountsUpdated.fire(true);
                    // Close dialog
                    Navigator.of(context).pop();
                  },
          ),
        ],
      ],
    );
  }
}
