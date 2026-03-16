import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/transaction/transaction_rule_provider.dart';

/// Dialog display that gives options for running manual rules
class TransactionRuleManualDialog extends ConsumerStatefulWidget {
  const TransactionRuleManualDialog({super.key});

  @override
  ConsumerState<TransactionRuleManualDialog> createState() => _TransactionRuleManualDialogState();
}

class _TransactionRuleManualDialogState extends ConsumerState<TransactionRuleManualDialog> {
  /// Local state for the "Force" override toggle
  bool _force = false;

  /// Returns the display content for our dialog
  Widget _buildForm(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pressing confirm will re-run rule application against all historical transactions. '
          'Be warned, this will overwrite anything that applies to a rule. Would you like to continue?',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Force Override", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Switch(value: _force, onChanged: (newValue) => setState(() => _force = newValue)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Overrides all transaction categories, even ones manually edited by you.",
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch if rules are already running to disable buttons
    final isRunning = ref.watch(transactionRulesProvider.select((s) => s.value?.isRunning ?? false));

    return SproutBaseDialogWidget(
      'Re-apply Transaction Rules',
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      submitButtonText: isRunning ? "Processing..." : "Continue",
      // Disable the button if the provider is already processing
      onSubmitClick: isRunning
          ? null
          : () async {
              // Trigger the manual refresh on our new Riverpod provider
              await ref.read(transactionRulesProvider.notifier).manualRefresh(force: _force);

              // Close the dialog upon successful trigger
              if (mounted) Navigator.of(context).pop();
            },
      child: _buildForm(theme),
    );
  }
}
