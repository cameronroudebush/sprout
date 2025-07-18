import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/api/base.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/transaction/provider.dart';

/// This class provides some basic capability that is required by our data driven providers
abstract class BaseProvider<T extends BaseAPI> with ChangeNotifier {
  /// The reference to the API this provider uses to get data from the backend.
  final T api;

  /// Tracks our disposal state to handle notification listener errors.
  bool _disposed = false;

  BaseProvider(this.api);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// When a user first logs in successfully, this will be called so you can do what you need to
  Future<void> onLogin();

  /// When a user logs out, this will be called
  Future<void> onLogout();

  /// When this provider is initialized this will be called. Note that no auth will be ready!
  Future<void> onInit();

  /// Creates a ChangeNotifierProvider for the given type.
  static ChangeNotifierProvider<T> createProvider<T extends BaseProvider<BaseAPI>>(T provider) {
    provider.onInit();
    return ChangeNotifierProvider<T>(create: (context) => provider);
  }

  /// Returns every provider that has been initialized by the app in a list like format
  static List<BaseProvider> getAllProviders(BuildContext context) {
    return [
      Provider.of<AuthProvider>(context, listen: false),
      Provider.of<AccountProvider>(context, listen: false),
      Provider.of<ConfigProvider>(context, listen: false),
      Provider.of<SSEProvider>(context, listen: false),
      Provider.of<NetWorthProvider>(context, listen: false),
      Provider.of<TransactionProvider>(context, listen: false),
    ];
  }
}
