import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
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
      SproutRouter.router.pushReplacementNamed(targetRoute, queryParameters: queryParameters ?? {});
    }
  }

  /// Redirects to the last page we were on.
  static void back(BuildContext context) {
    Navigator.pop(context);
  }

  /// Redirects to the transaction page with the given category name. If the category name is invalid, no redirect is completed.
  static Future<void> redirectToCatFilter(String cat, {bool navigateOnUnknown = false}) async {
    cat = cat.trim();
    final catProvider = ServiceLocator.get<CategoryProvider>();
    final cats = catProvider.categories;
    // If we are missing categories, go ahead and try to request them
    if (cats.isEmpty) await catProvider.loadUpdatedCategories();
    // Navigate to transactions on node click
    String? id = ServiceLocator.get<CategoryProvider>().categories.firstWhereOrNull((x) => x.name == cat)?.id;
    if (cat == "Unknown") {
      id = "unknown";
    }
    if (id != null || navigateOnUnknown) {
      SproutNavigator.redirect("transactions", queryParameters: {'cat': id});
    }
  }

  /// Redirects to the specific account
  static Future<void> redirectToAccount(Account account) async {
    SproutNavigator.redirect("account", queryParameters: {'acc': account.id});
  }
}
