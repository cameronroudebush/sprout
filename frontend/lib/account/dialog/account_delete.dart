import 'package:flutter/material.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';

/// A dialog that confirms account deletion
class AccountDeleteDialog extends StatelessWidget {
  final Account account;

  const AccountDeleteDialog({super.key, required this.account});

  /// Uses the API to request a delete to this account
  Future<void> _requestAccountDelete(BuildContext context) async {
    final accountProvider = ServiceLocator.get<AccountProvider>();
    await accountProvider.api.deleteAccount(account);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Center(child: TextWidget(referenceSize: 2, text: 'Delete account')),
      content: TextWidget(
        text:
            'Removing ${account.name} will remove all transactions and history linked to this account. This cannot be undone!',
      ),
      actions: <Widget>[
        Row(
          spacing: 12,
          children: [
            // Cancel
            Expanded(
              child: ButtonWidget(
                text: "Cancel",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            // Delete
            Expanded(
              child: ButtonWidget(
                text: "Delete",
                color: theme.colorScheme.onError,
                onPressed: () => _requestAccountDelete(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
