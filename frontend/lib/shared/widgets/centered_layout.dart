import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/icon.dart';

enum SproutLayoutType {
  /// Standard background
  standard,

  /// Error badge overlay
  error,
}

/// A reusable layout wrapper that automatically styles itself based on the layout type used across simple pages.
class SproutCenteredLayout extends StatelessWidget {
  final SproutLayoutType type;
  final String title;
  final String? description;
  final Widget? body;
  final Widget? actions;
  final double maxWidth;

  const SproutCenteredLayout({
    super.key,
    this.type = SproutLayoutType.standard,
    required this.title,
    this.description,
    this.body,
    this.actions,
    this.maxWidth = 450,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double iconSize = 96;
    final Color iconBgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.5);

    final content = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branded Logo Header
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconSize * 0.25),
                      decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                      child: SproutIcon(iconSize),
                    ),
                    if (type == SproutLayoutType.error) _buildErrorBadge(theme),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                // Description
                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],

                // Dynamic Body Content (Forms, Cards, etc.)
                if (body != null) ...[
                  const SizedBox(height: 20),
                  body!,
                ],

                // Action Controls
                if (actions != null) ...[
                  const SizedBox(height: 16),
                  actions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8)),
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildErrorBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        shape: BoxShape.circle,
        border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
      ),
      child: Icon(Icons.cloud_off_rounded, size: 20, color: theme.colorScheme.onError),
    );
  }
}
