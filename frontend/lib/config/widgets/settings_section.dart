import 'package:flutter/material.dart';

/// A wrapper widget that groups multiple settings tiles into a single logical section.
///
/// Displays a stylized uppercase [title] above a [Card] containing the [children].
class SettingSection extends StatelessWidget {
  /// The header text displayed above the settings card.
  final String title;

  /// The list of settings tiles (usually [SwitchSettingTile] or [ActionSettingTile]).
  final List<Widget> children;

  const SettingSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
