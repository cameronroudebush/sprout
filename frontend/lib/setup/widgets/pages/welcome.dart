import 'package:flutter/material.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';
import 'package:sprout/shared/widgets/icon.dart';

/// This page contains the initial page welcoming the user to the app
class WelcomeSetupPage extends StatelessWidget {
  final VoidCallback nextPage;
  final bool isDesktop;
  const WelcomeSetupPage(this.nextPage, this.isDesktop, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SetupPageWrapper(
      isDesktop,
      "Get Started",
      nextPage,
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: <Widget>[
            // Hero Icon or Logo
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: SproutIcon(108),
            ),

            // Main Title
            Text(
              'Welcome to Sprout!',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: isDesktop ? 64 : 36,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle / Intro text
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
              child: Text(
                "Take control of your financial future.",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),

            // Descriptive Body
            Text(
              "Sprout is your personal, self-hostable finance tracker designed to give you a crystal-clear view of your net worth and transaction history. Let's get started on your journey.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: isDesktop ? 18 : 16,
              ),
            ),
            const SizedBox(height: 8),

            // Feature Pills
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildFeatureChip(context, Icons.lock_outline, "Private"),
                _buildFeatureChip(context, Icons.analytics_outlined, "Insights"),
                _buildFeatureChip(context, Icons.cloud_off_outlined, "Self-Hosted"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a chip used to display the most important features
  Widget _buildFeatureChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
