import 'package:flutter/material.dart';

/// A reusable informational banner card with an icon and contextual text.
class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const InfoCard({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.iconColor,
    this.padding = const EdgeInsets.all(12.0),
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        spacing: 10,
        children: [
          Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary,
            size: 20,
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
