import 'package:flutter/material.dart';

/// A widget used to display a message for when there are no subscriptions detected
class SubscriptionsEmptyWidget extends StatelessWidget {
  const SubscriptionsEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Icon(Icons.calendar_month, size: 64, color: theme.colorScheme.primary),
              Text(
                "No Subscriptions Found",
                style: theme.textTheme.titleLarge,
              ),
              Text(
                "Sprout detects recurring bills automatically from your history. Check back later to see if Sprout has detected any.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
