import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/api.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/api/client.dart';
import 'package:sprout/api/config.dart';
import 'package:sprout/api/setup.dart';
import 'package:sprout/api/transaction.dart';
import 'package:sprout/api/user.dart';
import 'package:sprout/login.dart';
import 'package:sprout/provider/auth.dart';
import 'package:sprout/shell.dart';
import 'package:sprout/widgets/text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Grab theme
  final themeStr = await rootBundle.loadString('assets/dark.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(Main(theme: theme));
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
  String? setupPosition = null;
  bool _failedToConnect = false;

  // API References
  late final RESTClient client;
  late final ConfigAPI configAPI;
  late final UserAPI userAPI;
  late final SetupAPI setupAPI;
  late final AccountAPI accountAPI;
  late final TransactionAPI transactionAPI;

  MainState({required this.theme}) {
    client = RESTClient(getBaseURL());
    configAPI = ConfigAPI(client);
    userAPI = UserAPI(client);
    setupAPI = SetupAPI(client);
    accountAPI = AccountAPI(client);
    transactionAPI = TransactionAPI(client);
  }

  @override
  void initState() {
    super.initState();
    _checkIfSetupNeeded();
  }

  /// Checks if the setup process is needed.
  Future<void> _checkIfSetupNeeded() async {
    try {
      await configAPI.populateUnsecureConfig();
      String position = configAPI.unsecureConfig!.firstTimeSetupPosition;
      setState(() {
        setupPosition = position;
      });
    } catch (e) {
      // This normally means we failed to connect to the backend.
      setState(() {
        _failedToConnect = true;
      });
    }
  }

  String getBaseURL() {
    Uri uri = Uri.base;
    return kDebugMode ? 'http://${uri.host}:8001' : 'https://${uri.host}/api';
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Build the various API providers
        Provider<RESTClient>(create: (_) => client),
        Provider<UserAPI>(create: (_) => userAPI),
        Provider<SetupAPI>(create: (_) => setupAPI),
        Provider<ConfigAPI>(create: (_) => configAPI),
        Provider<AccountAPI>(create: (_) => accountAPI),
        Provider<TransactionAPI>(create: (_) => transactionAPI),
        // Change Notifiers
        ChangeNotifierProvider(create: (context) => AuthProvider(userAPI)),
        ChangeNotifierProxyProvider<AuthProvider, AccountProvider>(
          update: (context, auth, previousMessages) => AccountProvider(accountAPI, auth),
          create: (BuildContext context) => AccountProvider(accountAPI, null),
        ),
      ],
      child: Consumer2<AuthProvider, AccountProvider>(
        builder: (context, authProvider, accountProvider, child) {
          Widget page;

          if (_failedToConnect) {
            page = Scaffold(
              body: Center(
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
              configAPI.populateConfig();
              // If setup is complete AND logged in
              page = const SproutAppShell();
            } else {
              // If setup is complete but NOT logged in
              page = const LoginPage();
            }
          } else {
            // If setup is not complete
            page = SproutAppShell(
              isSetup: true,
              onSetupSuccess: () {
                setState(() {
                  setupPosition = "complete";
                });
              },
            );
          }

          return MaterialApp(home: page, theme: theme, title: "Sprout");
        },
      ),
    );
  }
}
