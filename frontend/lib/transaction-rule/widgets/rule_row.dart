import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction-rule/provider.dart';
import 'package:sprout/transaction-rule/widgets/rule_info.dart';
import 'package:sprout/transaction/models/transaction_rule.dart';
import 'package:sprout/transaction/widgets/category_icon.dart';

/// Renders a transaction rule in a modern, card-based format.
class TransactionRuleRow extends StatelessWidget {
  final TransactionRule rule;
  final int index;

  const TransactionRuleRow(this.rule, {required this.index, super.key});

  void _delete(BuildContext context) {
    final provider = ServiceLocator.get<TransactionRuleProvider>();
    showDialog(
      context: context,
      builder: (_) => SproutDialogWidget(
        'Delete Rule',
        showCloseDialogButton: true,
        closeButtonText: "Cancel",
        showSubmitButton: true,
        submitButtonText: "Delete",
        submitButtonStyle: AppTheme.errorButton,
        onSubmitClick: () {
          provider.delete(rule);
          Navigator.of(context).pop();
        },
        child: const TextWidget(text: 'Removing this transaction rule cannot be undone.'),
      ),
    );
  }

  void _edit(BuildContext context) {
    showDialog(context: context, builder: (_) => TransactionRuleInfo(rule));
  }

  Widget _buildPill(BuildContext context, String text, {bool isValue = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final pillColor = isValue ? colorScheme.secondary : colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: pillColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pillColor, width: 1),
      ),
      child: TextWidget(
        text: text,
        style: TextStyle(color: pillColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Builds the value pills, handling the 'OR' logic for description types.
  List<Widget> _buildValuePills(BuildContext context) {
    final bool isDescriptionOr = rule.type == TransactionRuleType.description && rule.value.contains('|');

    if (!isDescriptionOr) {
      return [_buildPill(context, '"${rule.value}"', isValue: true)];
    }

    final values = rule.value.split('|').map((v) => v.trim()).toList();
    final List<Widget> pills = [];

    for (int i = 0; i < values.length; i++) {
      pills.add(_buildPill(context, '"${values[i]}"', isValue: true));
      if (i < values.length - 1) {
        pills.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextWidget(
              text: 'OR',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
    return pills;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String condition = rule.strict ? 'is exactly' : 'contains';

    return Consumer<TransactionRuleProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6.0,
                            runSpacing: 4.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextWidget(text: 'IF', style: textTheme.titleMedium),
                              _buildPill(context, rule.type.name.toCapitalized),
                              _buildPill(context, condition),
                              ..._buildValuePills(context),
                            ],
                          ),
                        ),
                        Switch(
                          value: rule.enabled,
                          onChanged: (bool isEnabled) {
                            final newRule = rule.copyWith(enabled: isEnabled);
                            provider.edit(newRule);
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Wrap(
                        spacing: 8.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextWidget(text: 'THEN categorize as', style: textTheme.titleMedium),
                          if (rule.category != null) ...[
                            CategoryIcon(rule.category!, avatarSize: 20),
                            TextWidget(
                              text: rule.category!.name,
                              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ] else
                            TextWidget(
                              text: 'Uncategorized',
                              style: textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: TextWidget(
                            text: 'Applied to ${rule.matches} transactions',
                            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            SproutTooltip(
                              message: "Edit Rule",
                              child: IconButton(
                                onPressed: () => _edit(context),
                                icon: const Icon(Icons.edit_outlined),
                                style: AppTheme.primaryButton,
                              ),
                            ),
                            SproutTooltip(
                              message: "Delete Rule",
                              child: IconButton(
                                onPressed: () => _delete(context),
                                icon: Icon(Icons.delete_outline),
                                style: AppTheme.errorButton,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
