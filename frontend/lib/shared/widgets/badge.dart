import 'package:flutter/material.dart' hide Badge;

enum BadgeVariant { primary, secondary, outline, destructive }

/// Compact label styled as a badge, with theme-aware variants.
class Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final BadgeVariant variant;

  const Badge({
    super.key,
    required this.label,
    this.icon,
    this.variant = BadgeVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = switch (variant) {
      BadgeVariant.primary => (
          background: theme.colorScheme.primary,
          foreground: theme.colorScheme.onPrimary,
          border: theme.colorScheme.primary,
        ),
      BadgeVariant.secondary => (
          background: theme.colorScheme.secondaryContainer,
          foreground: theme.colorScheme.onSecondaryContainer,
          border: theme.colorScheme.secondaryContainer,
        ),
      BadgeVariant.outline => (
          background: Colors.transparent,
          foreground: theme.colorScheme.onSurfaceVariant,
          border: theme.colorScheme.outlineVariant,
        ),
      BadgeVariant.destructive => (
          background: theme.colorScheme.error,
          foreground: theme.colorScheme.onError,
          border: theme.colorScheme.error,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (icon != null) Icon(icon, size: 14, color: colors.foreground),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
