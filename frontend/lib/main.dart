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
import 'package:sprout/core/widgets/app_bar.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/api.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/setup/api.dart';
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

  // Register all the providers
  ServiceLocator.register<ConfigProvider>(ConfigProvider(ConfigAPI(client), packageInfo));
  ServiceLocator.register<AuthProvider>(AuthProvider(AuthAPI(client)));
  ServiceLocator.register<SSEProvider>(SSEProvider(SSEAPI(client)));
  ServiceLocator.register<AccountProvider>(AccountProvider(AccountAPI(client)));
  ServiceLocator.register<SetupProvider>(SetupProvider(SetupAPI(client)));
  ServiceLocator.register<NetWorthProvider>(NetWorthProvider(NetWorthAPI(client)));
  ServiceLocator.register<TransactionProvider>(TransactionProvider(TransactionAPI(client)));
  ServiceLocator.register<UserProvider>(UserProvider(UserAPI(client)));

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

  MainState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ConfigProvider>(
      builder: (context, authProvider, configProvider, child) {
        final failedToConnect = configProvider.failedToConnect;
        final setupPosition = configProvider.unsecureConfig?.firstTimeSetupPosition;
        Widget page;
        final screenHeight = MediaQuery.of(context).size.height;

        if (failedToConnect) {
          page = Scaffold(
            body: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/logo/color-transparent-no-tag.png'),
                      width: MediaQuery.of(context).size.height * .6,
                    ),
                    SizedBox(height: 12),
                    TextWidget(
                      referenceSize: 1.5,
                      text: "Failed to connect to the backend. Please ensure the backend is running and accessible.",
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (setupPosition == null) {
          page = Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.height * .3,
              height: MediaQuery.of(context).size.height * .3,
              child: CircularProgressIndicator(strokeWidth: MediaQuery.of(context).size.height * .01),
            ),
          );
        } else if (setupPosition == "complete") {
          if (authProvider.isLoggedIn) {
            // If setup is complete AND logged in
            page = const SproutAppShell();
          } else {
            ServiceLocator.get<AuthProvider>().checkInitialLoginStatus();
            // If setup is complete but NOT logged in
            page = const LoginPage();
          }
        } else {
          // If setup is not complete
          page = Scaffold(
            appBar: SproutAppBar(screenHeight: screenHeight),
            body: SetupPage(
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
