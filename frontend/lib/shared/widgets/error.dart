import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/icon.dart';
import 'package:sprout/theme/absolute_dark.dart';
import 'package:sprout/theme/helpers.dart';

/// Full-screen error state when the app fails to initialize its core configuration
class SproutErrorPage extends ConsumerWidget {
  final Object error;
  final VoidCallback onRetry;

  const SproutErrorPage({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = absoluteDarkTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Branding & Error Icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const SproutIcon(124),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.error,
                    child: Icon(Icons.priority_high_rounded, size: 20, color: theme.colorScheme.onError),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                "Critical Error",
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                "Sprout encountered a critical error while in use.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // Technical Details Card
              SproutCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.terminal_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Technical Details",
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          error.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Try Again"),
                  style: ThemeHelpers.primaryButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
