import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/auth/widgets/login.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/connection_failure.dart';
import 'package:sprout/routes/connection_setup.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/routes/util/shell.dart';
import 'package:sprout/shared/widgets/lock.dart';

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
  final notifier = RouterNotifier(ref);

  final router = GoRouter(
    refreshListenable: notifier,
    initialLocation: '/login',
    redirect: (context, state) => _authRedirect(ref, state),
    routes: [
      // Routes that don't require Auth
      GoRoute(path: '/locked', builder: (context, state) => const SproutLockWidget()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/setup', builder: (context, state) => const Placeholder()), // TODO Implement setup capabilities
      GoRoute(path: '/connection/setup', builder: (context, state) => const ConnectionSetupPage()),
      GoRoute(path: '/connection/failure', builder: (context, state) => const ConnectionFailurePage()),
      // Routes that do require auth
      ShellRoute(
        builder: (context, state, child) => SproutShell(state: state, child: child),
        routes: authenticatedRoutes.map((route) {
          return GoRoute(path: route.path, builder: route.builder);
        }).toList(),
      ),
    ],
  );

  NavigationProvider.router = router;
  return router;
});

String? _authRedirect(Ref ref, GoRouterState state) {
  final connUrlState = ref.read(connectionUrlProvider);
  final authState = ref.read(authProvider);
  final bioState = ref.read(biometricsProvider);

  // Check if we're biometric locked
  if (bioState.isLocked) return "/locked";

  // Connection URL Check
  if (connUrlState.isLoading) return null;
  if (connUrlState.value == null || connUrlState.value!.isEmpty) return '/connection/setup';

  // Server Connection Check
  final configNotifier = ref.read(unsecureConfigProvider.notifier);
  if (configNotifier.failedToConnect) return '/connection/failure';

  // Setup Mode Check
  if (ref.read(authProvider.notifier).isSetupMode) return '/setup';

  // Authentication Logic
  final isLoggedIn = authState.value != null;
  final isGoingToLogin = state.matchedLocation == '/login';

  if (!isLoggedIn) {
    // If not logged in and not on login page, send to login
    return isGoingToLogin ? null : '/login';
  }

  // If already logged in but trying to go to login, kick to home
  if (isLoggedIn && isGoingToLogin) {
    return '/';
  }

  return null;
}
