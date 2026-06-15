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

  final router = GoRouter(
    navigatorKey: NavigationProvider.key,
    refreshListenable: notifier,
    redirect: (context, state) => _authRedirect(ref, state),
    routes: [
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) {
          final splashAsync = ref.watch(sproutSplashManagerProvider);
          return NoTransitionPage(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SproutLoadingIndicator(
                message: "Initializing...",
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
  final splashAsync = ref.read(sproutSplashManagerProvider);
  final currentPath = state.uri.path;

  if (splashAsync.isLoading) {
    if (_intendedPath == null && currentPath != '/loading') {
      _intendedPath = state.uri.toString();
    }
    return currentPath == '/loading' ? null : '/loading';
  }

  final connUrlState = ref.read(connectionUrlProvider);
  final authState = ref.read(authProvider);

  if (authState.isLoading) return null; // Wait for auth/config

  // Connection URL Check
  if (connUrlState.isLoading) return null;
  if (connUrlState.value == null || connUrlState.value!.isEmpty) return '/connection/setup';

  // Server Connection Check
  final configNotifier = ref.read(unsecureConfigProvider.notifier);
  if (configNotifier.failedToConnect) return '/connection/failure';

  // Setup Mode Check
  if (ref.read(authProvider.notifier).isSetupMode) return '/setup';

  // Authentication Logic
  final bioState = ref.read(biometricsProvider);
  final isLoggedIn = authState.value != null;

  // Check biometric lock state
  final userConfigAsync = ref.read(userConfigProvider);
  final secureModeEnabled = userConfigAsync.value?.secureMode ?? false;
  final needsBioCheck = !kIsWeb && secureModeEnabled && isLoggedIn;

  if (needsBioCheck && bioState.isLocked) {
    if (_intendedPath == null && currentPath != '/locked' && currentPath != '/loading') {
      _intendedPath = state.uri.toString();
    }
    return currentPath == '/locked' ? null : '/locked';
  }

  final isGoingToLogin = currentPath == '/login';

  if (!isLoggedIn) {
    // If not logged in and not on login page, send to login
    return isGoingToLogin ? null : '/login';
  }

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
