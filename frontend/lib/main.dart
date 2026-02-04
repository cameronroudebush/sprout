import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/client/extended_api_client.dart';
import 'package:sprout/core/provider/init.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/core/router.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/notification/firebase.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/transaction-rule/transaction_rule.provider.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  await applyDefaultAPI();

  // Register all the providers
  ServiceLocator.register<ConfigProvider>(ConfigProvider(ConfigApi(), packageInfo));
  ServiceLocator.register<AuthProvider>(AuthProvider(AuthApi()));
  ServiceLocator.register<NotificationProvider>(NotificationProvider(NotificationApi()));
  ServiceLocator.register<UserProvider>(UserProvider(UserApi()));
  ServiceLocator.register<SSEProvider>(SSEProvider(CoreApi()));
  ServiceLocator.register<AccountProvider>(AccountProvider(AccountApi()));
  ServiceLocator.register<NetWorthProvider>(NetWorthProvider(NetWorthApi()));
  ServiceLocator.register<TransactionProvider>(TransactionProvider(TransactionApi()));
  ServiceLocator.register<UserConfigProvider>(UserConfigProvider(UserConfigApi()));
  ServiceLocator.register<HoldingProvider>(HoldingProvider(HoldingApi()));
  ServiceLocator.register<TransactionRuleProvider>(TransactionRuleProvider(TransactionRuleApi()));
  ServiceLocator.register<CategoryProvider>(CategoryProvider(CategoryApi()));
  ServiceLocator.register<CashFlowProvider>(CashFlowProvider(CashFlowApi()));
  ServiceLocator.register<ChatProvider>(ChatProvider(ChatApi()));

  await FirebaseNotificationProvider.configure(null);

  runApp(
    MultiProvider(
      providers: [
        ServiceLocator.createProvider<ConfigProvider>(),
        ServiceLocator.createProvider<UserProvider>(),
        ServiceLocator.createProvider<SSEProvider>(),
        ServiceLocator.createProvider<AccountProvider>(),
        ServiceLocator.createProvider<NetWorthProvider>(),
        ServiceLocator.createProvider<TransactionProvider>(),
        ServiceLocator.createProvider<UserConfigProvider>(),
        ServiceLocator.createProvider<HoldingProvider>(),
        ServiceLocator.createProvider<TransactionRuleProvider>(),
        ServiceLocator.createProvider<CategoryProvider>(),
        ServiceLocator.createProvider<CashFlowProvider>(),
        ServiceLocator.createProvider<NotificationProvider>(),
        ServiceLocator.createProvider<ChatProvider>(),

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
