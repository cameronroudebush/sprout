import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprout/core/router.dart';

/// A class used to navigate to different pages
class SproutNavigator {
  /// Used fore redirections
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  /// Redirects to the given page name
  static void redirect(String page, {Map<String, dynamic>? queryParameters}) {
    final currentRoute = SproutRouter.router.state.topRoute?.name;
    final targetRoute = page.toLowerCase();
    if (currentRoute != targetRoute) {
      if (kIsWeb) {
        SproutRouter.router.goNamed(targetRoute, queryParameters: queryParameters ?? {});
      } else {
        SproutRouter.router.pushNamed(targetRoute, queryParameters: queryParameters ?? {});
      }
    }
  }
}
