import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/client/extended_api_client.dart';
import 'package:sprout/core/provider/init.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/router.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/notification/firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // Apply default API requirements
  await applyDefaultAPI();
  // Register all the providers
  ServiceLocator.registerAll(packageInfo);
  // Configure firebase for notification listening
  await FirebaseNotificationProvider.configure(null);

  runApp(
    MultiProvider(
      providers: [
        // Create all the providers we'll need
        ...ServiceLocator.createAllProviders(),

        // Create a future that waits for all the providers to be initialized, in order
        ChangeNotifierProvider<InitializationNotifier>(
          create: (_) {
            final notifier = InitializationNotifier();
            notifier.initialize();
            return notifier;
          },
          lazy: false, // Keep this to ensure it runs immediately
        ),
      ],
      child: Main(),
    ),
  );
}

/// This page contains the process for when the application is first started
class Main extends StatelessWidget {
  const Main({super.key});

  Widget _getLoadingIndicator(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Theme(
      data: AppTheme.dark,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SproutScaffold(
          child: Center(
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
  Widget build(BuildContext context) {
    return Consumer<InitializationNotifier>(
      builder: (context, value, child) {
        final init = value;
        switch (init.status) {
          case InitStatus.loading:
            return _getLoadingIndicator(context);

          default:
            FirebaseNotificationProvider.checkLaunchNotification();
            return MaterialApp.router(
              routerConfig: SproutRouter.router,
              title: "Sprout",
              theme: AppTheme.dark,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.dark,
              scaffoldMessengerKey: ServiceLocator.scaffoldMessengerKey,
            );
        }
      },
    );
  }
}
