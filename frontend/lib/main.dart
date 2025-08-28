import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/api.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/auth/api.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/config/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/api/client.dart';
import 'package:sprout/core/api/sse.dart';
import 'package:sprout/core/provider/init.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/core/router.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/holding/api.dart';
import 'package:sprout/holding/provider.dart';
import 'package:sprout/net-worth/api.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/setup/api.dart';
import 'package:sprout/setup/provider.dart';
import 'package:sprout/transaction/api.dart';
import 'package:sprout/transaction/provider.dart';
import 'package:sprout/user/api.dart';
import 'package:sprout/user/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // Create base API client
  final client = RESTClient();
  await client.setBaseUrl();

  // Register all the providers
  ServiceLocator.register<ConfigProvider>(ConfigProvider(ConfigAPI(client), packageInfo));
  ServiceLocator.register<AuthProvider>(AuthProvider(AuthAPI(client)));
  ServiceLocator.register<SSEProvider>(SSEProvider(SSEAPI(client)));
  ServiceLocator.register<AccountProvider>(AccountProvider(AccountAPI(client)));
  ServiceLocator.register<SetupProvider>(SetupProvider(SetupAPI(client)));
  ServiceLocator.register<NetWorthProvider>(NetWorthProvider(NetWorthAPI(client)));
  ServiceLocator.register<TransactionProvider>(TransactionProvider(TransactionAPI(client)));
  ServiceLocator.register<UserProvider>(UserProvider(UserAPI(client)));
  ServiceLocator.register<HoldingProvider>(HoldingProvider(HoldingAPI(client)));

  runApp(
    MultiProvider(
      providers: [
        ServiceLocator.createProvider<ConfigProvider>(),
        ServiceLocator.createProvider<AuthProvider>(),
        ServiceLocator.createProvider<SSEProvider>(),
        ServiceLocator.createProvider<AccountProvider>(),
        ServiceLocator.createProvider<SetupProvider>(),
        ServiceLocator.createProvider<NetWorthProvider>(),
        ServiceLocator.createProvider<TransactionProvider>(),
        ServiceLocator.createProvider<UserProvider>(),
        ServiceLocator.createProvider<HoldingProvider>(),

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
