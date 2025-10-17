import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/cash-flow/provider.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/api/base.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/holding/provider.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/setup/provider.dart';
import 'package:sprout/transaction-rule/provider.dart';
import 'package:sprout/transaction/provider.dart';
import 'package:sprout/user/provider.dart';

/// This class provides lookups to other providers
class ServiceLocator {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Internal service locator
  static final GetIt _sl = GetIt.instance;

  /// Registers the given provider as a singleton
  static T register<T extends BaseProvider>(T prov) {
    return _sl.registerSingleton<T>(prov);
  }

  /// Creates a ChangeNotifierProvider for the given type.
  static ChangeNotifierProvider<T> createProvider<T extends BaseProvider<BaseAPI>>() {
    final prov = _sl<T>();
    return ChangeNotifierProvider.value(value: prov);
  }

  /// All provider types that are registered with GetIt.
  static const _allProviderTypes = <Type>[
    AuthProvider,
    ConfigProvider,
    UserProvider,
    AccountProvider,
    SSEProvider,
    NetWorthProvider,
    TransactionProvider,
    TransactionRuleProvider,
    CategoryProvider,
    HoldingProvider,
    SetupProvider,
    CashFlowProvider,
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
}
