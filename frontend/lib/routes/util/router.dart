import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/widgets/login.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/routes/util/shell.dart';

/// This provides the GoRouter for all of Sprout so pages know what is available
final routerProvider = Provider<GoRouter>((ref) {
  // Watch states we need for tracking data changes
  ref.watch(authProvider);
  ref.watch(unsecureConfigProvider);
  ref.watch(connectionUrlProvider);

  final router = GoRouter(
    // initialLocation: '/login',
    // We pass the ref to our redirect
    redirect: (context, state) => _authRedirect(ref, state),
    routes: [
      // Routes that don't require Auth
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // TODO
      GoRoute(path: '/setup', builder: (context, state) => const Placeholder()),
      GoRoute(path: '/connection-setup', builder: (context, state) => const Placeholder()),
      GoRoute(path: '/connection-failure', builder: (context, state) => const Placeholder()),
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
  final authState = ref.read(authProvider);
  final connUrlState = ref.read(connectionUrlProvider);

  // Connection URL Check
  if (connUrlState.value == null) return '/connection-setup';

  // Server Connection Check
  final configNotifier = ref.read(unsecureConfigProvider.notifier);
  if (configNotifier.failedToConnect) return '/connection-failure';

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
