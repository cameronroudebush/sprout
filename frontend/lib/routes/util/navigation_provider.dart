import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';

part 'navigation_provider.g.dart';

// A simple provider to hold the current path
@riverpod
class CurrentRoute extends _$CurrentRoute {
  @override
  String build() => NavigationProvider.currentRoute;

  void update(String newPath) => state = newPath;
}

/// A provider used to navigate to different pages
class NavigationProvider {
  /// The GlobalKey for the root navigator, used by GoRouter
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  /// Helper to get the current GoRouter instance from the context or the key
  static late GoRouter router;

  /// Returns the current top-level route path
  static String get currentRoute {
    final lastMatch = router.routerDelegate.currentConfiguration.last;
    final location = lastMatch.matchedLocation;
    return location;
  }

  /// Redirects (using push or go) to the given path or route name
  static Future<void> redirect(String path, {Map<String, dynamic>? queryParameters}) async {
    final target = path.startsWith('/') ? path : '/$path';
    final params = queryParameters?.map((k, v) => MapEntry(k, v.toString())) ?? {};

    // Don't allow same page navigation
    final currentPage = router.state.path;
    final bool isSamePath = currentPage == path || currentPage == '/$path';
    const MapEquality mapEquality = MapEquality();
    final bool isSameParams = mapEquality.equals(router.state.pathParameters, queryParameters ?? {});
    if (isSamePath && isSameParams) {
      return;
    }
    final uri = Uri(path: target, queryParameters: params).toString();

    if (kIsWeb) {
      router.go(uri);
    } else {
      router.push(uri);
    }
  }

  /// Standard back navigation
  static void back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  /// Redirects to the transaction page with a category filter
  /// [navigateOnUnknown] If we should still navigate even if the category is unknown
  static Future<void> redirectToCatFilter(WidgetRef ref, String cat, {bool navigateOnUnknown = false}) async {
    final categoryName = cat.trim();
    final categories = ref.read(categoriesProvider).value ?? [];

    String? id;
    if (categoryName.toLowerCase() == "unknown") {
      id = "unknown";
    } else {
      id = categories.firstWhereOrNull((x) => x.name == categoryName)?.id;
    }

    if (id != null || navigateOnUnknown) {
      redirect("/transactions", queryParameters: {'categoryId': id ?? 'unknown'});
    }
  }

  /// Redirects to a specific account detail page
  static Future<void> redirectToAccount(Account account) async {
    await redirect("/account", queryParameters: {'acc': account.id});
  }
}
