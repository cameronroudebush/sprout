import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/core/utils/formatters.dart';

/// This class defines a page to render in sprout
class SproutPage {
  /// The page we want to render
  final Widget Function(BuildContext context, GoRouterState state) page;

  /// An icon to identify what this page is
  final IconData icon;

  /// The name of this page
  final String label;

  /// Custom buttons to display on the app bar
  final Widget Function(BuildContext context, bool isDesktop)? buttonBuilder;

  /// If we want to display the full logo on the app bar. Directly conflicts with [buttonBuilder]
  final bool useFullLogo;

  /// If we should render the navigation bar. Disabling this also makes it so the user can't navigate to it.
  final bool renderNav;

  /// If this should show as a button on the sidenav or even bottom nav for the user to use.
  final bool canNavigateTo;

  /// If the app bar should be rendered at the top of the page
  final bool renderAppBar;

  /// If we should wrap this element with a scrollable area
  final bool scrollWrapper;

  /// If this should be shown on the bottom navigation. Default is false.
  final bool showOnBottomNav;

  /// If we should show on the sidenav. Default is true.
  final bool showOnSideNav;

  /// How much padding to apply to the side of the page by default.
  final double pagePadding;

  /// Returns the path for the router
  get path {
    if (label.toLowerCase() == "home") {
      return "/";
    } else {
      return "/${label.kebabCase}";
    }
  }

  SproutPage(
    this.page,
    this.label, {
    required this.icon,
    this.buttonBuilder,
    bool? renderNav,
    this.renderAppBar = true,
    bool? canNavigateTo,
    this.scrollWrapper = true,
    this.useFullLogo = false,
    this.showOnBottomNav = false,
    this.showOnSideNav = true,
    this.pagePadding = 12,
  }) : renderNav = renderNav ?? true,
       canNavigateTo = canNavigateTo ?? renderNav ?? true;
}
