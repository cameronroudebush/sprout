import 'package:flutter/material.dart';

/// A settings tile used for navigation or triggering an immediate action.
///
/// Displays a [title], an optional [subtitle], and a [trailing] widget
class ActionSettingTile extends StatelessWidget {
  /// The primary label for the action.
  final String title;

  /// Optional description displayed below the title.
  final String? subtitle;

  /// The icon displayed at the start of the tile.
  final IconData icon;

  /// Custom widget displayed at the end of the tile (defaults to chevron icon).
  final Widget? trailing;

  /// Callback triggered when the tile is tapped.
  final VoidCallback? onTap;

  const ActionSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }
}
