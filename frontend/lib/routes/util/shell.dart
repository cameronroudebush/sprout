import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/route.dart';
import 'package:sprout/shared/widgets/app_bar.dart';
import 'package:sprout/shared/widgets/lifecycle_observer.dart';
import 'package:sprout/shared/widgets/sidenav.dart';

/// A lightweight wrapper that provides persistent navigation (e.g., Side/Bottom Nav).
class SproutShell extends ConsumerWidget {
  final Widget child;

  const SproutShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine layout based on screen size
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final bioState = ref.watch(biometricsProvider);
    final isLocked = bioState.isLocked;

    return SproutLifecycleObserver(
      child: Scaffold(
        appBar: const SproutAppBar(),
        body: Row(
          children: [
            if (isDesktop) SproutSideNav(isDesktop: isDesktop), // Show side nav on large screens
            Expanded(child: child),
          ],
        ),
        drawer: (isLocked)
            ? null
            : isDesktop
            ? null
            : Drawer(
                child: SafeArea(child: SproutSideNav(isDesktop: isDesktop)),
              ),
        bottomNavigationBar: isDesktop ? null : _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final navRoutes = authenticatedRoutes.where((r) => r.showInBottomNav).toList();

    final currentPath = NavigationProvider.currentRoute;
    final currentIndex = navRoutes.indexWhere((r) => r.path == currentPath);

    return BottomNavigationBar(
      currentIndex: currentIndex < 0 ? 0 : currentIndex,
      type: BottomNavigationBarType.fixed,
      items: navRoutes.map((route) {
        return BottomNavigationBarItem(icon: Icon(route.icon), label: route.label);
      }).toList(),
      onTap: (index) {
        final selectedRoute = navRoutes[index];
        NavigationProvider.redirect(selectedRoute.path);
      },
    );
  }
}
