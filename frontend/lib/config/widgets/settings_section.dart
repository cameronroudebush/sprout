import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/card.dart';

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
            title,
            style: theme.textTheme.bodyLarge?.copyWith(),
          ),
        ),
        SproutCard(
          child: Material(
            color: Colors.transparent,
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
