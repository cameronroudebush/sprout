import 'package:flutter/material.dart';

/// A settings tile with a [Switch] toggle.
class SwitchSettingTile extends StatelessWidget {
  /// The primary label for the setting.
  final String title;

  /// Detailed description displayed below the title.
  final String subtitle;

  /// The icon displayed at the start of the tile.
  final IconData icon;

  /// The current state of the switch.
  final bool value;

  /// Callback triggered when the switch is toggled.
  final ValueChanged<bool> onChanged;

  const SwitchSettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
