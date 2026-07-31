import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/api/api.dart';

/// Specifies a route in Sprout
class SproutRoute {
  final String path;
  final String label;
  final IconData icon;
  final Widget Function(BuildContext, GoRouterState) builder;
  final bool showInSidebar;

  /// What priority that these get bottom navigation room. Lowest number is highest priority
  final num bottomNavPriority;
  final String? category;

  /// Allows you to customize enabled state of a route
  final bool Function(APIConfig config, UserConfig? userConfig)? enabled;

  /// Nested child routes
  final List<SproutRoute>? routes;

  const SproutRoute(
      {required this.path,
      required this.label,
      required this.icon,
      required this.builder,
      this.showInSidebar = true,
      this.bottomNavPriority = -1,
      this.category,
      this.routes,
      this.enabled});
}
