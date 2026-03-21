import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/transaction/widgets/transaction_rule_edit.dart';

/// Renders a transaction rule in a modern, card-based format.
class TransactionRuleRow extends ConsumerWidget {
  final TransactionRule rule;
  final int index;

  const TransactionRuleRow(this.rule, {required this.index, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final disabledColor = theme.disabledColor;
    final defaultStyle = textTheme.bodyMedium;
    final disabledStyle = defaultStyle?.copyWith(color: disabledColor, fontStyle: FontStyle.italic);
    final effectiveStyle = rule.enabled ? defaultStyle : disabledStyle;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => showSproutPopup(context: context, builder: (_) => TransactionRuleEdit(rule)),
      leading: CircleAvatar(
        radius: 15,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          rule.order.toString(),
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: _buildMatchText(effectiveStyle, theme),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: _buildCatRow(disabledStyle, effectiveStyle, textTheme, disabledColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Text('${rule.matches} matches', style: textTheme.labelMedium),
          Icon(Icons.chevron_right, color: theme.disabledColor),
        ],
      ),
    );
  }

  /// Builds the category row to display who we're matching to
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
      ],
    );
  }

  /// Builds the text to display how we're matching our content
  Widget _buildMatchText(TextStyle? effectiveStyle, ThemeData theme) {
    final value = rule.value.replaceAll('|', ' OR ');
    final String condition = rule.strict ? 'is' : 'contains';
    final String type = rule.type.value;

    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: [
          TextSpan(
            text: 'IF ',
            style: theme.textTheme.labelMedium,
          ),
          if (rule.account != null) ...[
            const TextSpan(text: 'account is '),
            TextSpan(
              text: rule.account!.name,
              style: theme.textTheme.labelMedium?.copyWith(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  NavigationProvider.redirectToAccount(rule.account!);
                },
            ),
            const TextSpan(text: ' and '),
          ],
          TextSpan(text: '$type $condition ', style: theme.textTheme.labelMedium),
          TextSpan(
            text: '"$value"',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
      softWrap: true,
    );
  }
}
