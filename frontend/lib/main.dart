import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/notification/firebase_provider.dart';
import 'package:sprout/routes/util/router.dart';
import 'package:sprout/shared/providers/splash_time_provider.dart';
import 'package:sprout/shared/providers/widget_provider.dart';
import 'package:sprout/shared/widgets/error.dart';
import 'package:sprout/shared/widgets/lifecycle_observer.dart';
import 'package:sprout/shared/widgets/loading.dart';
import 'package:sprout/theme/absolute_dark.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final container = ProviderContainer();
  await container.read(firebaseProvider.notifier).configure();
  await container.read(widgetSyncProvider.notifier).initializeBackground();

  container.read(widgetSyncProvider);
  container.read(userProvider);

  runApp(UncontrolledProviderScope(container: container, child: const SproutApp()));
}

/// The main app entrypoint
class SproutApp extends ConsumerWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userConfigAsync = ref.watch(userConfigProvider);
    final splashAsync = ref.watch(sproutSplashManagerProvider);

    final isLoggingOut = ref.watch(authProvider.notifier).isLoggingOut;

    final isLoading = userConfigAsync.isLoading || splashAsync.isLoading;
    final hasError = userConfigAsync.hasError || splashAsync.hasError;

    if (isLoading) {
      final String loadingMessage;
      if (isLoggingOut) {
        loadingMessage = "Logging out...";
      } else if (splashAsync.isLoading) {
        loadingMessage = "Initializing...";
      } else {
        loadingMessage = "Loading user data...";
      }

      return Theme(
        data: absoluteDarkTheme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SproutLoadingIndicator(
            message: loadingMessage,
            animate: splashAsync.isLoading && !isLoggingOut,
          ),
        ),
      );
    }

    if (hasError) {
      final error = userConfigAsync.error ?? splashAsync.error ?? 'Unknown initialization error';
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: absoluteDarkTheme,
        home: SproutErrorPage(
          error: error,
          onRetry: () {
            ref.invalidate(userConfigProvider);
            ref.invalidate(sproutSplashManagerProvider);
          },
        ),
      );
    }

    final userConfig = userConfigAsync.value;
    final userConfigNotifier = ref.read(userConfigProvider.notifier);
    final theme = userConfigNotifier.activeTheme(userConfig);
    final router = ref.watch(routerProvider);

    return SproutLifecycleObserver(
      child: MaterialApp.router(
        routerConfig: router,
        title: "Sprout",
        theme: theme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
