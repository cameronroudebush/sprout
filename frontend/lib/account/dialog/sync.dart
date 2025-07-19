import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/core/widgets/button.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        return AlertDialog(
          title: Center(child: TextWidget(referenceSize: 2, text: 'Re-Sync')),
          content: TextWidget(
            referenceSize: 1,
            text: 'Welcome back! Would you like to re-sync your accounts to get updated data from fixed accounts?',
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWidget(
                  text: "Cancel",
                  minSize: screenWidth * .25,
                  color: Theme.of(context).colorScheme.onError,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                // Sync button
                ButtonWidget(
                  text: "Sync",
                  minSize: screenWidth * .25,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await accountProvider.manualSync();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
