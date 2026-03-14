import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/theme/helpers.dart';

/// This page is used to display when we fail to connect to our backend API
class ConnectionFailurePage extends ConsumerWidget {
  const ConnectionFailurePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connUrl = ref.watch(connectionUrlProvider).value ?? "Not Set";

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Icon(Icons.cloud_off_rounded, size: 80, color: theme.colorScheme.error),
              const SizedBox(height: 12),

              // Title
              Text("Connection Failed", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Description
              Text(
                "Sprout is unable to communicate with your server. Please check your settings and try again.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Troubleshoot Card
              SproutCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Configuration",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(theme, "URL", connUrl),
                      const SizedBox(height: 16),
                      Text(
                        "Troubleshooting Steps:",
                        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildStep(theme, "Ensure the Sprout Docker container is running."),
                      _buildStep(theme, "If remote, make sure your URL above is correct."),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                spacing: 12,
                children: [
                  // Only allow connection setup on mobile
                  if (!kIsWeb)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          NavigationProvider.redirect('/connection/setup');
                        },
                        icon: Icon(Icons.settings, color: theme.colorScheme.secondaryContainer),
                        label: const Text("Edit URL"),
                        style: ThemeHelpers.primaryButton,
                      ),
                    ),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // Invalidate the config to trigger a retry
                        ref.invalidate(unsecureConfigProvider);
                        NavigationProvider.redirect('/');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ThemeHelpers.secondaryButton,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an info row to show some specific information
  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds a step for troubleshooting
  Widget _buildStep(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: theme.colorScheme.primary),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
