import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
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

  /// Redirects to the transaction page with the given category name. If the category name is invalid, no redirect is completed.
  static void redirectToCatFilter(String cat) {
    // Navigate to transactions on node click
    String? id = ServiceLocator.get<CategoryProvider>().categories.firstWhereOrNull((x) => x.name == cat)?.id;
    if (cat == "Unknown") {
      id = "unknown";
    }
    if (id != null) {
      SproutNavigator.redirect("transactions", queryParameters: {'cat': id});
    }
  }
}
