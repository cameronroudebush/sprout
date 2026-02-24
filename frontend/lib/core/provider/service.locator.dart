import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/client/extended_api_client.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/core/provider/widget.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/transaction-rule/transaction_rule.provider.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/user_provider.dart';

/// This class provides lookups to other providers
class ServiceLocator {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

  /// Internal service locator
  static final GetIt _sl = GetIt.instance;

  /// Registers the given provider as a singleton
  static T _register<T extends BaseProvider>(T prov) {
    // Don't register if already registered
    if (_sl.isRegistered<T>()) return _sl.get<T>();
    return _sl.registerSingleton<T>(prov);
  }

  /// Registers all providers for the application.
  /// Can be called in main() or any background isolate.
  static void registerAll(PackageInfo packageInfo) {
    _register(ConfigProvider(ConfigApi(), packageInfo));
    _register(AuthProvider(AuthApi()));
    _register(NotificationProvider(NotificationApi()));
    _register(UserProvider(UserApi()));
    _register(SSEProvider(CoreApi()));
    _register(AccountProvider(AccountApi()));
    _register(NetWorthProvider(NetWorthApi()));
    _register(TransactionProvider(TransactionApi()));
    _register(UserConfigProvider(UserConfigApi()));
    _register(HoldingProvider(HoldingApi()));
    _register(TransactionRuleProvider(TransactionRuleApi()));
    _register(CategoryProvider(CategoryApi()));
    _register(CashFlowProvider(CashFlowApi()));
    _register(ChatProvider(ChatApi()));
    _register(BiometricProvider(ApiClient()));
    _register(WidgetProvider(CoreApi()));
  }

  /// Creates a ChangeNotifierProvider for the given type.
  static ChangeNotifierProvider<T> _createProvider<T extends BaseProvider>() {
    final prov = _sl<T>();
    return ChangeNotifierProvider.value(value: prov);
  }

  /// Generates the list of providers needed for the MultiProvider in main.dart
  static List<SingleChildWidget> createAllProviders() {
    return [
      _createProvider<ConfigProvider>(),
      _createProvider<UserProvider>(),
      _createProvider<SSEProvider>(),
      _createProvider<AccountProvider>(),
      _createProvider<NetWorthProvider>(),
      _createProvider<TransactionProvider>(),
      _createProvider<UserConfigProvider>(),
      _createProvider<HoldingProvider>(),
      _createProvider<TransactionRuleProvider>(),
      _createProvider<CategoryProvider>(),
      _createProvider<CashFlowProvider>(),
      _createProvider<NotificationProvider>(),
      _createProvider<ChatProvider>(),
      _createProvider<BiometricProvider>(),
      _createProvider<WidgetProvider>(),
    ];
  }

  /// All provider types that are registered with GetIt.
  static const _allProviderTypes = <Type>[
    AuthProvider,
    NotificationProvider,
    UserProvider,
    UserConfigProvider,
    ConfigProvider,
    AccountProvider,
    SSEProvider,
    NetWorthProvider,
    TransactionProvider,
    TransactionRuleProvider,
    CategoryProvider,
    HoldingProvider,
    CashFlowProvider,
    ChatProvider,
    BiometricProvider,
    WidgetProvider,
  ];

  /// Returns every provider that has been initialized by the app in a list like format
  /// It gets them explicitly from the service locator by their specific types.
  static List<BaseProvider> getAllProviders() {
    return _allProviderTypes.map((type) => _sl.get<BaseProvider>(type: type)).toList();
  }

  /// Returns a single provider from the service locator.
  static T get<T extends BaseProvider>() {
    return _sl.get<T>();
  }

  /// Calls post login on all available providers
  static Future<void> postLogin() async {
    final providers = ServiceLocator.getAllProviders();
    // Order does matter on these so execute in order.
    for (final provider in providers) {
      try {
        await provider.postLogin();
      } catch (e) {
        LoggerService.error("Failed to load data for provider ${provider.runtimeType}: $e");
      }
    }
  }

  /// Initializes everything needed for a background isolate to function headless.
  /// This configures the API, registers all providers, and applies stored authentication.
  static Future<void> setupBackgroundIsolate() async {
    // Configure the API client
    await applyDefaultAPI();
    // Gather platform info and register all providers
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    registerAll(packageInfo);
    // Load auth credentials from secure storage to authenticate the API and prepare for usage
    final authProvider = get<AuthProvider>();
    await authProvider.applyDefaultAuth();
  }
}
