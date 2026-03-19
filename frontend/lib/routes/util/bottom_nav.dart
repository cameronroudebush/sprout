import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/routes/util/mobile_more_sheet.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/route.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';

/// The bottom navigation used for mobile displays
class SproutBottomNav extends ConsumerWidget {
  final String currentPath;

  const SproutBottomNav({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final otherPrimaryRoutes = authenticatedRoutes.where((r) => r.showInBottomNav && r.path != '/').toList();
    final dashboardRoute = authenticatedRoutes.firstWhere((r) => r.path == '/');

    // Reconstruct the list to force Dashboard into the center
    final List<dynamic> displayItems = [
      ...otherPrimaryRoutes.sublist(0, 2),
      dashboardRoute, // The Centerpiece
      ...otherPrimaryRoutes.sublist(2),
      'MENU_ACTION',
    ];

    // Calculate selection logic based on our new custom order
    int effectiveIndex = 0;
    bool hasMatch = false;

    for (int i = 0; i < displayItems.length; i++) {
      final item = displayItems[i];
      if (item is SproutRoute && item.path == currentPath) {
        effectiveIndex = i;
        hasMatch = true;
        break;
      }
    }

    // If no primary match, check if it's a "More" route to highlight the Menu (last index)
    if (!hasMatch) {
      final isMoreRoute = authenticatedRoutes.any((r) => r.path == currentPath && !r.showInBottomNav);
      if (isMoreRoute) {
        effectiveIndex = displayItems.length - 1;
        hasMatch = true;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 4)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
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
            iconSize: 28,
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
