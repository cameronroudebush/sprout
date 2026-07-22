import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/centered_layout.dart';
import 'package:sprout/theme/helpers.dart';

class ConnectionFailurePage extends ConsumerWidget {
  const ConnectionFailurePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connUrl = ref.watch(connectionUrlProvider).value ?? "Not Set";

    return SproutCenteredLayout(
      type: SproutLayoutType.error,
      title: "Connection Failed",
      description: "Sprout is unable to communicate with your server. Please check your settings and try again.",
      maxWidth: 500,
      body: SproutCard(
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
              _buildStep(theme, "Ensure that Sprout is running."),
              _buildStep(theme, "If remote, make sure your URL above is correct."),
            ],
          ),
        ),
      ),
      actions: Row(
        spacing: 12,
        children: [
          if (!kIsWeb)
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  await ref.read(unsecureConfigProvider.notifier).setConnectionUrl(null);
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
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

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
