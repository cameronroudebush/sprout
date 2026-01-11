import 'package:flutter/material.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/state_tracker.dart';

import '../transaction_rule.provider.dart';

/// Dialog display that gives options for running manual rules
class TransactionRuleManualDialog extends StatefulWidget {
  const TransactionRuleManualDialog({super.key});

  @override
  State<TransactionRuleManualDialog> createState() => _TransactionRuleManualDialogState();
}

class _TransactionRuleManualDialogState extends StateTracker<TransactionRuleManualDialog> {
  bool _force = false;

  @override
  Map<dynamic, DataRequest> get requests => {};

  /// Returns the display content for our dialog
  Widget _getForm() {
    return Column(
      spacing: 16,
      children: [
        // Give info
        Text(
          'Pressing confirm will re-run rule application against all historical transactions. Be warned, this will overwrite anything that applies to a rule. Would you like to continue?',
          textAlign: TextAlign.center,
        ),
        // Options
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              spacing: 16,
              children: [
                Text("Force", style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _force,
                  onChanged: (newValue) {
                    setState(() {
                      _force = newValue;
                    });
                  },
                ),
              ],
            ),
            Text(
              "Overrides all transactions categories, even ones manually edited by the user.",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SproutDialogWidget(
      'Re-apply Transaction Rules',
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      closeButtonStyle: AppTheme.primaryButton,
      showSubmitButton: true,
      submitButtonText: "Continue",
      submitButtonStyle: AppTheme.secondaryButton,
      onSubmitClick: () async {
        final transactionRuleProvider = ServiceLocator.get<TransactionRuleProvider>();
        transactionRuleProvider.manualRefresh(force: _force);
        // Close dialog
        Navigator.of(context).pop();
      },
      child: _getForm(),
    );
  }
}
