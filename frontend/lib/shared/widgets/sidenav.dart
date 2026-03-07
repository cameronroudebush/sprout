import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/route.dart';
import 'package:sprout/user/models/extensions/user_extensions.dart';

/// A widget that is used to render the side navigation for Sprout
class SproutSideNav extends ConsumerWidget {
  final Widget? child;
  final bool isDesktop;

  const SproutSideNav({super.key, this.child, required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Material(elevation: 2.0, child: _InternalSideNavContent(isDesktop: isDesktop)),
        ),
        VerticalDivider(width: 4, color: theme.colorScheme.secondary),
        if (child != null) Expanded(child: child!),
      ],
    );
  }
}

/// Internal navigation content that renders the actual sidenav
class _InternalSideNavContent extends ConsumerWidget {
  final bool isDesktop;

  const _InternalSideNavContent({required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authProvider).value;
    final authNotifier = ref.read(authProvider.notifier);

    // Filter and build the navigation items from your Router definition
    final navItems = authenticatedRoutes.where((page) => page.showInSidebar).mapIndexed((index, page) {
      return ListTile(
        leading: Icon(page.icon),
        title: Text(page.label),
        selected: NavigationProvider.currentRoute == page.path,
        onTap: () {
          if (!isDesktop) Navigator.pop(context); // Close drawer if mobile
          NavigationProvider.redirect(page.path);
        },
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (!isDesktop) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Image.asset('assets/logo/color-transparent-no-tag.png', height: 48),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ],
              // Map items with dividers
              ...navItems.expand((item) => [item, const Divider(height: 1)]),
            ],
          ),
        ),

        // User Profile & Settings Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: PopupMenuButton<String>(
            offset: const Offset(0, -110),
            onSelected: (value) {
              if (value == 'settings') {
                NavigationProvider.redirect("settings");
              } else if (value == 'logout') {
                authNotifier.logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text('Logout', style: TextStyle(color: theme.colorScheme.error)),
                  contentPadding: EdgeInsets.zero,
                  onTap: authNotifier.logout,
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authUser?.prettyName ?? "User",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.unfold_more),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
