import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/route.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/shared/widgets/logo.dart';
import 'package:sprout/user/models/extensions/user_extensions.dart';
import 'package:sprout/user/widgets/user_avatar.dart';

/// A widget that is used to render the side navigation for Sprout. Only used on desktop displays.
class SproutSideNav extends ConsumerWidget {
  final Widget? child;

  const SproutSideNav({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const SizedBox(
          width: 260,
          child: _InternalSideNavContent(),
        ),
        if (child != null) Expanded(child: child!),
      ],
    );
  }
}

/// Internal navigation content that renders the actual sidenav
class _InternalSideNavContent extends ConsumerWidget {
  const _InternalSideNavContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authProvider).value;
    final authNotifier = ref.read(authProvider.notifier);
    final currentPath = ref.watch(currentRouteProvider);

    final navItems = authenticatedRoutes.where((page) => page.showInSidebar).toList();
    final groupedItems = groupBy<SproutRoute, String?>(navItems, (route) => route.category);
    final navBackgroundColor = theme.cardTheme.color ?? theme.cardColor;

    return Material(
      elevation: 4.0,
      color: navBackgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox.shrink(),
                const SproutLogo(224),
                const SizedBox.shrink(),
              ],
            ),
          ),

          // Scrollable Dynamic Grouped Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: groupedItems.entries.map((entry) {
                final categoryName = entry.key;
                final routes = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Render Category Header title if key value is defined
                    if (categoryName != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 6, top: 6),
                        child: Text(
                          categoryName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.75),
                          ),
                        ),
                      ),

                    // Render the corresponding navigation tiles
                    ...routes.map((page) {
                      final isSelected = currentPath == page.path;
                      const borderRadius = 12.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: InkWell(
                          onTap: () => NavigationProvider.redirect(page.path),
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? theme.colorScheme.secondaryContainer : Colors.transparent,
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            child: Row(
                              spacing: 12,
                              children: [
                                Icon(
                                  page.icon,
                                  color: isSelected
                                      ? theme.colorScheme.onSecondaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                Text(
                                  page.label,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onSecondaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),

          // User Profile Section
          _UserProfileTile(authUser: authUser, onLogout: authNotifier.logout, currentPath: currentPath),
        ],
      ),
    );
  }
}

/// The user profile tile that allows configuration based on the user with a settings menu
class _UserProfileTile extends StatelessWidget {
  /// The current authorized user
  final User? authUser;

  /// What to do on logout
  final VoidCallback onLogout;
  final String currentPath;

  const _UserProfileTile({required this.authUser, required this.onLogout, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSettings = currentPath == "/settings";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MenuAnchor(
        alignmentOffset: const Offset(250, -40),
        style: MenuStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        builder: (context, controller, child) {
          return InkWell(
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            borderRadius: BorderRadius.circular(16),
            hoverColor: theme.colorScheme.primary.withOpacity(0.15),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSettings
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: Row(
                spacing: 12,
                children: [
                  UserAvatar(authUser),
                  // User name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authUser?.prettyName ?? "",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSettings ? theme.colorScheme.onSecondaryContainer : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Account Settings",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSettings ? theme.colorScheme.onSecondaryContainer : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icon just to show we can open the menu
                  Icon(
                    Icons.more_vert,
                    size: 18,
                    color: isSettings ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          );
        },
        menuChildren: [
          MenuItemButton(
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(196, 52)),
              backgroundColor: WidgetStateProperty.all(
                isSettings ? theme.colorScheme.secondaryContainer : null,
              ),
              foregroundColor: WidgetStateProperty.all(
                isSettings ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onBackground,
              ),
            ),
            leadingIcon:
                Icon(Icons.settings_outlined, color: isSettings ? theme.colorScheme.onSecondaryContainer : null),
            onPressed: () => NavigationProvider.redirect("settings"),
            child: const Text('Settings'),
          ),
          MenuItemButton(
            style: ButtonStyle(minimumSize: WidgetStateProperty.all(const Size(196, 52))),
            leadingIcon: Icon(Icons.logout, color: theme.colorScheme.error),
            onPressed: onLogout,
            child: Text('Logout', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
