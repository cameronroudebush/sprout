import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sprout/notification/firebase_provider.dart';
import 'package:sprout/routes/util/router.dart';
import 'package:sprout/theme/absolute_dark.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Provider that fires first
final initializationProvider = FutureProvider<void>((ref) async {});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final container = ProviderContainer();
  // Setup firebase, using cached credentials as provided
  await container.read(firebaseProvider.notifier).configure();
  runApp(UncontrolledProviderScope(container: container, child: SproutApp()));
}

/// The main app entrypoint
class SproutApp extends ConsumerWidget {
  const SproutApp({super.key});

  Widget _getLoadingIndicator(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Theme(
      data: absoluteDarkTheme,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: mediaQuery.height * .3,
              height: mediaQuery.height * .3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: mediaQuery.height * .3,
                    height: mediaQuery.height * .3,
                    child: CircularProgressIndicator(strokeWidth: mediaQuery.height * .01),
                  ),
                  Image.asset(
                    'assets/icon/color.png',
                    height: mediaQuery.height * .15,
                    width: mediaQuery.height * .15,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initStatus = ref.watch(initializationProvider);

    return initStatus.when(
      loading: () => _getLoadingIndicator(context),
      error: (error, stackTrace) => MaterialApp(
        theme: absoluteDarkTheme,
        home: Scaffold(body: Center(child: Text('Failed to initialize: $error'))),
      ),
      data: (_) {
        final configNotifier = ref.watch(userConfigProvider.notifier);
        final router = ref.watch(routerProvider);

        return MaterialApp.router(
          routerConfig: router,
          title: "Sprout",
          theme: configNotifier.activeLightTheme,
          darkTheme: configNotifier.activeDarkTheme,
          themeMode: configNotifier.themeMode,
        );
      },
    );
  }
}
