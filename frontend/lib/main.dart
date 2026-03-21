import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sprout/notification/firebase_provider.dart';
import 'package:sprout/routes/util/router.dart';
import 'package:sprout/shared/providers/widget_provider.dart';
import 'package:sprout/shared/widgets/loading.dart';
import 'package:sprout/theme/absolute_dark.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/user_provider.dart';

/// Provider that fires first
final initializationProvider = FutureProvider<void>((ref) async {
  // Setup firebase, using cached credentials as provided
  await ref.read(firebaseProvider.notifier).configure();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final container = ProviderContainer();
  // Make sure the widget provider is syncing
  container.read(widgetSyncProvider);
  // Make sure the user provider is tracked
  container.read(userProvider);
  runApp(UncontrolledProviderScope(container: container, child: SproutApp()));
}

/// The main app entrypoint
class SproutApp extends ConsumerWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initStatus = ref.watch(initializationProvider);
    final userConfigAsync = ref.watch(userConfigProvider);

    return initStatus.when(
      loading: () => Theme(
          data: absoluteDarkTheme,
          child: Directionality(textDirection: TextDirection.ltr, child: SproutLoadingIndicator())),
      error: (error, stackTrace) => MaterialApp(
        theme: absoluteDarkTheme,
        home: Scaffold(body: Center(child: Text('Failed to initialize: $error'))),
      ),
      data: (_) {
        if (userConfigAsync.isLoading && !userConfigAsync.hasValue) return SproutLoadingIndicator();

        final userConfig = ref.watch(userConfigProvider).value;
        final userConfigNotifier = ref.read(userConfigProvider.notifier);
        final theme = userConfigNotifier.activeTheme(userConfig);
        final router = ref.watch(routerProvider);

        return MaterialApp.router(
          routerConfig: router,
          title: "Sprout",
          theme: theme,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
