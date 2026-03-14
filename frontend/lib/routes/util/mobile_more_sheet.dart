import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/theme/helpers.dart';

/// Used to display a grid in a sheet of additional routes on mobile that are not shown on develop
class SproutMoreSheet extends ConsumerWidget {
  const SproutMoreSheet({super.key});

  /// Returns a greeting for our user
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Top of the morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).value;

    // Filter routes: Sidebar enabled but NOT in the bottom bar
    final moreRoutes = authenticatedRoutes.where((r) => r.showInSidebar && !r.showInBottomNav).toList();

    return SproutBaseDialogWidget(
      "${_getGreeting()} ${user?.username ?? 'User'}!",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          // Sub-header text
          Text(
            "Where are we headed today?",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            textAlign: TextAlign.center,
          ),

          // Build the grid of pages
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 16),
            itemCount: moreRoutes.length,
            itemBuilder: (context, index) {
              final route = moreRoutes[index];
              final isSelected = NavigationProvider.currentRoute == route.path;

              return _MoreGridTile(
                icon: route.icon,
                label: route.label,
                isSelected: isSelected,
                onTap: () {
                  Navigator.pop(context);
                  NavigationProvider.redirect(route.path);
                },
              );
            },
          ),

          // Build bottom actions
          _buildBottomActions(context, ref),
        ],
      ),
    );
  }

  /// Constructs the bottom row allowing for settings access for the user
  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSettings = NavigationProvider.currentRoute == '/settings';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              NavigationProvider.redirect('/settings');
            },
            icon: Icon(isSettings ? Icons.settings : Icons.settings_outlined, size: 20),
            label: const Text("Settings"),
            style: isSettings ? ThemeHelpers.primaryButton : ThemeHelpers.secondaryButton,
          ),
          FilledButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text("Logout"),
            style: ThemeHelpers.errorButton,
          ),
        ],
      ),
    );
  }
}

/// Represents a tile to be rendered in our grid for directing to another page
class _MoreGridTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoreGridTile({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Squircle shape using dynamic colors
              color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: isSelected ? colorScheme.onPrimary : colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
