import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
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
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/core/shell.dart';
import 'package:sprout/core/widgets/connect_fail.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/holding/api.dart';
import 'package:sprout/holding/provider.dart';
import 'package:sprout/net-worth/api.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/setup/api.dart';
import 'package:sprout/setup/connection.dart';
import 'package:sprout/setup/provider.dart';
import 'package:sprout/setup/setup.dart';
import 'package:sprout/transaction/api.dart';
import 'package:sprout/transaction/provider.dart';
import 'package:sprout/user/api.dart';
import 'package:sprout/user/login.dart';
import 'package:sprout/user/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Grab theme
  final themeStr = await rootBundle.loadString('assets/dark.json');
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

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
      ],
      child: Main(theme: theme),
    ),
  );
}

/// This page contains the process for when the application is first started
class Main extends StatefulWidget {
  final ThemeData theme;
  const Main({super.key, required this.theme});

  @override
  State<Main> createState() => MainState(theme: theme);
}

class MainState extends State<Main> {
  final ThemeData theme;
  bool hasTriedInitialLogin = false;

  MainState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ConfigProvider>(
      builder: (context, authProvider, configProvider, child) {
        final mediaQuery = MediaQuery.of(context).size;
        final hasConnectionUrl = configProvider.api.client.hasConnectionUrl();
        final failedToConnect = configProvider.failedToConnect;
        final setupPosition = configProvider.unsecureConfig?.firstTimeSetupPosition;
        Widget page;

        if (!hasConnectionUrl) {
          page = SproutScaffold(
            applyAppBar: true,
            currentPage: "Setup",
            child: Padding(
              padding: EdgeInsetsGeometry.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  TextWidget(
                    referenceSize: 3,
                    text: "Connection Setup",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextWidget(
                    referenceSize: 1.25,
                    text:
                        "Due to Sprouts nature of being self hosted, you must provide a URL to connect to your instance. Please enter the URL below. You will be able to change this later if the connection fails.",
                  ),

                  ConnectionSetup(
                    onURLSet: () {
                      // Reload to render the normal connection
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (failedToConnect) {
          page = SproutScaffold(child: FailToConnectWidget());
        } else if (setupPosition == null) {
          page = SproutScaffold(
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
                      'assets/icon/favicon-color.png',
                      height: mediaQuery.height * .15,
                      width: mediaQuery.height * .15,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (setupPosition == "complete") {
          if (authProvider.isLoggedIn) {
            // If setup is complete AND logged in
            page = const SproutAppShell();
          } else {
            if (!hasTriedInitialLogin) {
              ServiceLocator.get<AuthProvider>().checkInitialLoginStatus();
              hasTriedInitialLogin = true;
            }
            // If setup is complete but NOT logged in
            page = const LoginPage();
          }
        } else {
          // If setup is not complete
          page = SproutScaffold(
            applyAppBar: true,
            currentPage: "Setup",
            child: SetupPage(
              onSetupSuccess: () {
                configProvider.populateUnsecureConfig();
              },
            ),
          );
        }

        return MaterialApp(
          home: page,
          theme: theme,
          title: "Sprout",
          scaffoldMessengerKey: ServiceLocator.scaffoldMessengerKey,
        );
      },
    );
  }
}
