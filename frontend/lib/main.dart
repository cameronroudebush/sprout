import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/client.dart';
import 'package:sprout/api/config.dart';
import 'package:sprout/api/setup.dart';
import 'package:sprout/api/user.dart';
import 'package:sprout/setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Grab theme
  final themeStr = await rootBundle.loadString('assets/dark.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  MyApp({Key? key, required this.theme}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Uri uri = Uri.base;
    String baseUrl = kDebugMode
        ? 'http://${uri.host}:8001'
        : 'https://${uri.host}/api';

    return MultiProvider(
      providers: [
        // Build the various API providers
        Provider<RESTClient>(create: (_) => RESTClient(baseUrl)),
        ProxyProvider<RESTClient, UserAPI>(
          update: (_, apiClient, __) => UserAPI(apiClient),
        ),
        ProxyProvider<RESTClient, SetupAPI>(
          update: (_, apiClient, __) => SetupAPI(apiClient),
        ),
        ProxyProvider<RESTClient, ConfigAPI>(
          update: (_, apiClient, __) => ConfigAPI(apiClient),
        ),
      ],
      child: MaterialApp(
        home: const SetupPage(),
        theme: theme,
        title: "Sprout",
      ),
    );
  }
}
