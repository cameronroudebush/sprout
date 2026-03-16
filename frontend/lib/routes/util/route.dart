import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
