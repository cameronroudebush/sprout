import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/text.dart';

/// A dialog that asks if you want to re-sync your accounts.
class SyncDialog extends StatefulWidget {
  const SyncDialog({super.key});

  @override
  State<SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<SyncDialog> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        return SproutDialogWidget(
          'Re-Sync',
          showCloseDialogButton: true,
          showSubmitButton: true,
          submitButtonText: "Sync",
          onSubmitClick: () async {
            Navigator.of(context).pop();
            await accountProvider.manualSync();
          },
          child: TextWidget(
            referenceSize: 1,
            text: 'Welcome back! Would you like to re-sync your accounts to get updated data from fixed accounts?',
          ),
        );
      },
    );
  }
}
