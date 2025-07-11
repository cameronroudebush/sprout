import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/account.dart';
import 'package:sprout/api/client.dart';
import 'package:sprout/api/config.dart';
import 'package:sprout/api/setup.dart';
import 'package:sprout/api/transaction.dart';
import 'package:sprout/api/user.dart';
import 'package:sprout/login.dart';
import 'package:sprout/setup.dart';

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
    dynamic unsecureConfig = await configAPI.getUnsecure();
    String position = unsecureConfig["firstTimeSetupPosition"];
    setState(() {
      setupPosition = position;
    });
  }

  String getBaseURL() {
    Uri uri = Uri.base;
    return kDebugMode ? 'http://${uri.host}:8001' : 'https://${uri.host}/api';
  }

  @override
  Widget build(BuildContext context) {
    // Determine page to show
    dynamic page;
    if (setupPosition == "complete") {
      page = LoginPage();
    } else {
      page = SetupPage();
    }

    dynamic app = MaterialApp(home: page, theme: theme, title: "Sprout");

    return MultiProvider(
      providers: [
        // Build the various API providers
        Provider<RESTClient>(create: (_) => client),
        Provider<UserAPI>(create: (_) => userAPI),
        Provider<SetupAPI>(create: (_) => setupAPI),
        Provider<ConfigAPI>(create: (_) => configAPI),
        Provider<AccountAPI>(create: (_) => accountAPI),
        Provider<TransactionAPI>(create: (_) => transactionAPI),
      ],
      child: setupPosition == null
          ? Center(child: CircularProgressIndicator())
          : app,
    );
  }
}
