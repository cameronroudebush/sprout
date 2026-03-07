import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/routes/home.dart';

/// Specifies a route in Sprout
class SproutRoute {
  final String path;
  final String label;
  final IconData icon;
  final Widget Function(BuildContext, GoRouterState) builder;
  final bool showInSidebar;
  final bool showInBottomNav;

  const SproutRoute({
    required this.path,
    required this.label,
    required this.icon,
    required this.builder,
    this.showInSidebar = true,
    this.showInBottomNav = false,
  });
}

/// List of routes that require authentication
final List<SproutRoute> authenticatedRoutes = [
  SproutRoute(
    path: '/',
    label: 'Dashboard',
    icon: Icons.dashboard_rounded,
    showInBottomNav: true,
    builder: (context, state) => const HomePage(),
  ),
  SproutRoute(
    path: '/transactions',
    label: 'Transactions',
    icon: Icons.receipt_long_rounded,
    showInBottomNav: true,
    builder: (context, state) => const Placeholder(),
  ),
  SproutRoute(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings_rounded,
    showInBottomNav: true,
    builder: (context, state) => const Placeholder(),
  ),
];
