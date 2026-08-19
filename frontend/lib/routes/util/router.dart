import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/auth/widgets/login.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/connection_failure.dart';
import 'package:sprout/routes/connection_setup.dart';
import 'package:sprout/routes/setup.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/route.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/routes/util/shell.dart';
import 'package:sprout/shared/providers/splash_time_provider.dart';
import 'package:sprout/shared/widgets/loading.dart';
import 'package:sprout/shared/widgets/lock.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Intended initial redirect path
String? _intendedPath;

/// Defines a notifier that allows us to subscribe to necessary configuration
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Listens to the providers and notifies GoRouter to re-run the redirect
    _ref.listen(connectionUrlProvider, (_, __) => notifyListeners());
    _ref.listen(authProvider, (_, __) => notifyListeners());
    _ref.listen(unsecureConfigProvider, (_, __) => notifyListeners());
    _ref.listen(biometricsProvider, (_, __) => notifyListeners());
    _ref.listen(secureConfigProvider, (_, __) => notifyListeners());
    _ref.listen(userConfigProvider, (_, __) => notifyListeners());
  }
}

/// This provides the GoRouter for all of Sprout so pages know what is available
final routerProvider = Provider<GoRouter>((ref) {
  // Helps web track URL's while acting the same as mobile
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final notifier = RouterNotifier(ref);

  // Recursive mapper to automatically build nested GoRoute trees
  List<GoRoute> mapRoutes(List<SproutRoute> sproutRoutes, {bool isRoot = true}) {
    return sproutRoutes.map((route) {
      // GoRouter children must have relative paths. Clean up leading slashes for sub-routes.
      final cleanPath = !isRoot && route.path.startsWith('/') ? route.path.substring(1) : route.path;
      return GoRoute(
        path: cleanPath,
        pageBuilder: (context, state) => NoTransitionPage(child: route.builder(context, state)),
        routes: route.routes != null ? mapRoutes(route.routes!, isRoot: false) : const [],
      );
    }).toList();
  }

  /// Used to display in the loading indicator
  final loadingPhrases = [
    "Watering your compounding interest...",
    "Sowing the seeds of generational wealth...",
    "Fertilizing your portfolio...",
    "Harvesting your gains...",
    "Planting pennies, growing dollars...",
    "Tilling the financial soil...",
    "Convincing your savings to stretch a little taller...",
    "Pruning the bad investments...",
    "Watering the money tree...",
  ];

  final router = GoRouter(
    navigatorKey: NavigationProvider.key,
    refreshListenable: notifier,
    redirect: (context, state) => _authRedirect(ref, state),
    routes: [
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) {
          final splashAsync = ref.watch(sproutSplashManagerProvider);
          final randomPhrase = loadingPhrases[Random().nextInt(loadingPhrases.length)];
          return NoTransitionPage(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SproutLoadingIndicator(
                message: randomPhrase,
                animate: splashAsync.isLoading,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/locked',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SproutLockWidget(),
        ),
      ),
      // Routes that don't require Auth
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/setup',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SproutShell(child: SproutRouteWrapper(child: SetupPage()))),
      ),
      GoRoute(
        path: '/connection/setup',
        pageBuilder: (context, state) => const NoTransitionPage(child: ConnectionSetupPage()),
      ),
      GoRoute(
        path: '/connection/failure',
        pageBuilder: (context, state) => const NoTransitionPage(child: ConnectionFailurePage()),
      ),
      // Routes that do require auth
      ShellRoute(
        builder: (context, state, child) => SproutShell(state: state, child: child),
        routes: mapRoutes(authenticatedRoutes),
      ),
    ],
  );

  NavigationProvider.router = router;

  router.routerDelegate.addListener(() {
    final location = router.routerDelegate.currentConfiguration.last.matchedLocation;
    Future.microtask(() {
      ref.read(currentRouteProvider.notifier).update(location);
    });
  });
  return router;
});

String? _authRedirect(Ref ref, GoRouterState state) {
  final currentPath = state.uri.path;
  // Paths we should not allow the user to go to automatically after login.
  final corePaths = ["/loading", "/locked", "/login", "/setup", "/connection/setup", "/connection/failure"];

  // Read all relevant states
  final splashAsync = ref.read(sproutSplashManagerProvider);
  final authState = ref.read(authProvider);
  final connUrlState = ref.read(connectionUrlProvider);
  final apiConfigState = ref.read(secureConfigProvider);
  final unsecureConfigState = ref.read(unsecureConfigProvider);
  final userConfigState = ref.read(userConfigProvider);
  final isSetupMode = ref.read(authProvider.notifier).isSetupMode;

  // Determine if we are still waiting for core providers
  final isCoreLoading = splashAsync.isLoading || authState.isLoading || connUrlState.isLoading;

  // Determine if the user is logged in
  final isLoggedIn = authState.value != null;

  // If we are in setup mode, bypass the config loading check completely.
  // We don't want to redirect them to a loading screen while they are setting up their account.
  final isConfigLoading = isLoggedIn &&
      !isSetupMode &&
      (apiConfigState.isLoading ||
          apiConfigState.isRefreshing ||
          userConfigState.isLoading ||
          userConfigState.isRefreshing ||
          (!apiConfigState.hasValue && !apiConfigState.hasError) ||
          (!userConfigState.hasValue && !userConfigState.hasError));

  if (isCoreLoading || isConfigLoading) {
    if (_intendedPath == null && !corePaths.contains(currentPath)) {
      _intendedPath = state.uri.toString();
    }

    // If we are currently on the login page and the initial app boot (splash) is finished,
    // stay on the login page so its own spinner can show while configs load.
    if (currentPath == '/login' && !splashAsync.isLoading) {
      return null;
    }

    return currentPath == '/loading' ? null : '/loading';
  }

  if (connUrlState.value == null || connUrlState.value!.isEmpty) return '/connection/setup';

  // Server Connection Check
  final configNotifier = ref.read(unsecureConfigProvider.notifier);
  if (configNotifier.failedToConnect) return '/connection/failure';

  // Ensures that once in setup mode, the user STAYS in setup mode until completeSetup() is called.
  if (isSetupMode) return currentPath == '/setup' ? null : '/setup';

  // Authentication Logic
  final isGoingToLogin = currentPath == '/login';
  if (!isLoggedIn) {
    // If not logged in and not on login page, send to login
    return isGoingToLogin ? null : '/login';
  }

  // We now safely know configurations are fully loaded
  final apiConfig = apiConfigState.value;
  final userConfig = userConfigState.value;

  // Check biometric lock state
  final bioState = ref.read(biometricsProvider);
  final secureModeEnabled = userConfig?.secureMode ?? false;
  final needsBioCheck = !kIsWeb && secureModeEnabled && isLoggedIn;

  if (needsBioCheck && bioState.isLocked) {
    if (_intendedPath == null && currentPath != '/locked' && currentPath != '/loading') {
      _intendedPath = state.uri.toString();
    }
    return currentPath == '/locked' ? null : '/locked';
  }

  // Get the routes this specific user is allowed to see
  final allowedRoutes = getFilteredRoutes(
    unsecureConfigState.value!,
    apiConfig,
    userConfig,
    routes: authenticatedRoutes,
    restrictToSidebar: false,
  );

  // See if this path is an authenticated route, and if so, if they are allowed on it
  final isKnownAuthRoute = isPathInRoutes(currentPath, authenticatedRoutes);
  final isAllowedForUser = isPathInRoutes(currentPath, allowedRoutes);

  // If they try to access a route they don't have access to, go back to root
  if (isKnownAuthRoute && !isAllowedForUser) {
    _intendedPath = null;
    return '/';
  }

  // Restore Intended Path
  if (_intendedPath != null) {
    final target = _intendedPath!;
    _intendedPath = null;
    if (target != '/loading' && target != '/login' && target != '/locked') {
      return target;
    }
  }

  // If they are logged in but somehow stuck on /login or /loading without an intended path, push to home
  if (isGoingToLogin || currentPath == '/loading' || currentPath == '/locked') {
    return '/';
  }

  return null;
}
