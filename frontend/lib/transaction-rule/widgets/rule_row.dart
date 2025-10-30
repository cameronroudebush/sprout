import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction-rule/transaction_rule.provider.dart';
import 'package:sprout/transaction-rule/widgets/rule_info.dart';
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
        closeButtonStyle: AppTheme.primaryButton,
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

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context);
    });
  }

  Widget _buildCatRow(TextStyle? disabledStyle, TextStyle? effectiveStyle, TextTheme textTheme, Color disabledColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        const Icon(Icons.arrow_right_alt, size: 16),
        if (rule.category != null) ...[
          CategoryIcon(rule.category!, avatarSize: 16),
          Flexible(
            child: Text(rule.category!.name, style: effectiveStyle, overflow: TextOverflow.ellipsis),
          ),
        ] else
          Text('Uncategorized', style: disabledStyle),
        Text('(${rule.matches} matches)', style: textTheme.bodySmall?.copyWith(color: disabledColor)),
      ],
    );
  }

  Widget _buildMatchText(TextStyle? disabledStyle, TextStyle? effectiveStyle) {
    final value = rule.value.replaceAll('|', ' OR ');
    final String condition = rule.strict ? 'is' : 'contains';
    final String type = rule.type.value;
    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: [
          const TextSpan(
            text: 'IF ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '$type $condition '),
          TextSpan(
            text: '"$value"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      softWrap: true,
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final textTheme = theme.textTheme;
    return CircleAvatar(
      radius: 15, // Added for consistency
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(rule.order.toString(), style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final disabledColor = Colors.grey.shade600;
    final defaultStyle = textTheme.bodyMedium;
    final activeStyle = defaultStyle;
    final disabledStyle = defaultStyle?.copyWith(color: disabledColor, fontStyle: FontStyle.italic);
    final effectiveStyle = rule.enabled ? activeStyle : disabledStyle;

    return ListTile(
      leading: _buildAvatar(theme),
      title: _buildMatchText(disabledStyle, effectiveStyle),
      subtitle: _buildCatRow(disabledStyle, effectiveStyle, textTheme, disabledColor),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
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
              icon: const Icon(Icons.delete_outline),
              style: AppTheme.errorButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final disabledColor = Colors.grey.shade600;
    final defaultStyle = textTheme.bodyMedium;
    final activeStyle = defaultStyle;
    final disabledStyle = defaultStyle?.copyWith(color: disabledColor, fontStyle: FontStyle.italic);
    final effectiveStyle = rule.enabled ? activeStyle : disabledStyle;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rule order avatar
          _buildAvatar(theme),
          // Text and category organization
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMatchText(disabledStyle, effectiveStyle),
                _buildCatRow(disabledStyle, effectiveStyle, textTheme, disabledColor),
              ],
            ),
          ),

          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              IconButton(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit_outlined),
                style: AppTheme.primaryButton,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete_outline),
                style: AppTheme.errorButton,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
