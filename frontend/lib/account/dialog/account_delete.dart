import 'package:flutter/material.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/text.dart';

/// A dialog that confirms account deletion
class AccountDeleteDialog extends StatelessWidget {
  final Account account;

  const AccountDeleteDialog({super.key, required this.account});

  /// Uses the API to request a delete to this account
  Future<void> _requestAccountDelete(BuildContext context) async {
    final accountProvider = ServiceLocator.get<AccountProvider>();
    await accountProvider.api.deleteAccount(account);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    SproutNavigator.redirect("accounts");
  }

  @override
  Widget build(BuildContext context) {
    return SproutDialogWidget(
      'Delete account',
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      closeButtonStyle: AppTheme.primaryButton,
      showSubmitButton: true,
      submitButtonText: "Delete",
      submitButtonStyle: AppTheme.errorButton,
      onSubmitClick: () => _requestAccountDelete(context),
      child: TextWidget(
        text:
            'Removing ${account.name} will remove all transactions and history linked to this account. This cannot be undone!',
      ),
    );
  }
}
