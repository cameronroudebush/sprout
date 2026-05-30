import 'package:flutter/material.dart';

/// A settings tile that displays standard header metadata alongside a
/// custom layout component directly beneath it.
class SettingTile extends StatelessWidget {
  /// The primary label for the section.
  final String title;

  /// Optional description displayed below the title.
  final String? subtitle;

  /// The icon displayed at the start of the tile header.
  final IconData icon;

  /// The custom display element to render below the header metadata.
  final Widget child;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
