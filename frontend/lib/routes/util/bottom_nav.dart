import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/mobile_more_sheet.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/route.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/user/user_config_provider.dart';

/// The bottom navigation used for mobile displays
class SproutBottomNav extends ConsumerWidget {
  final String currentPath;

  const SproutBottomNav({super.key, required this.currentPath});

  /// Helper function to determine if a route matches the current path (including subroutes)
  bool isRouteMatch(String routePath, String currentPath) {
    if (routePath == '/') return currentPath == '/';
    return currentPath == routePath || currentPath.startsWith('$routePath/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final apiConfig = ref.watch(secureConfigProvider).value;
    final userConfig = ref.watch(userConfigProvider).value;
    final unsecureConfig = ref.watch(unsecureConfigProvider).value!;

    final filteredRoutes = getFilteredRoutes(unsecureConfig, apiConfig, userConfig);
    // Separate Dashboard from other candidate routes
    final dashboardRoute = authenticatedRoutes.firstWhere(
      (r) => r.path == '/',
      orElse: () => filteredRoutes.firstWhere((r) => r.path == '/'),
    );

    //  Filter candidate routes that have bottom nav priority (bottomNavPriority >= 0)
    //    and sort them by priority (lowest number = highest priority)
    final candidateRoutes = filteredRoutes.where((r) => r.path != '/' && r.bottomNavPriority >= 0).toList()
      ..sort((a, b) => a.bottomNavPriority.compareTo(b.bottomNavPriority));

    // Take the top 4 candidate routes to fill the 4 non-dashboard bottom slots
    final topRoutes = candidateRoutes.take(4).toList();

    // Construct display items (Exactly 5 items)
    // Slot 0, Slot 1 -> Left of Dashboard
    // Center -> Dashboard
    // Slot 2 -> Right of Dashboard
    // Slot 3 -> Menu action
    final List<dynamic> displayItems = [
      if (topRoutes.isNotEmpty) topRoutes[0],
      if (topRoutes.length > 1) topRoutes[1],
      dashboardRoute, // Centerpiece
      if (topRoutes.length > 2) topRoutes[2],
      'MENU_ACTION', // Slot 4: Menu for overflow
    ];

    final visibleRoutes = displayItems.whereType<SproutRoute>().toList();

    // Calculate selection logic based on our new custom order
    int effectiveIndex = 0;
    bool hasMatch = false;

    for (int i = 0; i < displayItems.length; i++) {
      final item = displayItems[i];
      if (item is SproutRoute && isRouteMatch(item.path, currentPath)) {
        effectiveIndex = i;
        hasMatch = true;
        break;
      }
    }

    // If no primary match, check if it's a "More" route to highlight the Menu (last index)
    if (!hasMatch) {
      final isOverflowRoute = filteredRoutes.any(
        (r) => !visibleRoutes.contains(r) && isRouteMatch(r.path, currentPath),
      );
      if (isOverflowRoute) {
        effectiveIndex = displayItems.length - 1;
        hasMatch = true;
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor, width: 4)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 54,
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            currentIndex: effectiveIndex,
            selectedItemColor: hasMatch ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            unselectedItemColor: theme.colorScheme.onSurfaceVariant,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            iconSize: 26,
            onTap: (index) {
              final selectedItem = displayItems[index];
              if (selectedItem is String) {
                _showMoreSheet(context);
              } else if (selectedItem is SproutRoute) {
                NavigationProvider.redirect(selectedItem.path);
              }
            },
            items: displayItems.map((item) {
              if (item is SproutRoute) {
                return BottomNavigationBarItem(icon: Icon(item.icon), label: item.label);
              }
              return const BottomNavigationBarItem(icon: Icon(Icons.menu_open_rounded), label: 'Menu');
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Opens the modal bottom sheet to allow seeing the rest of the pages
  void _showMoreSheet(BuildContext context) {
    showSproutPopup(context: context, builder: (context) => const SproutMoreSheet());
  }
}
