import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/auth/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/model/user.dart';

class AuthProvider extends BaseProvider<AuthAPI> {
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  // Constructor to check initial login status
  AuthProvider(super.api, BuildContext context) {
    _checkInitialLoginStatus(context);
  }

  /// Used to try to auto login if we have a JWT available
  Future<void> _checkInitialLoginStatus(BuildContext context) async {
    // Don't try to auto login when in setup if the user reset their db.
    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    if (configProvider.unsecureConfig?.firstTimeSetupPosition == "setup") return;
    User? user = await api.loginWithJWT(null);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<User?> login(String username, String password) async {
    User? user = await api.loginWithPassword(username, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    await api.logout();
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Tells all providers we have successfully logged in
  // Future<void> _informAllProvidersOfLogin() async {
  //   for (final provider in BaseProvider.getAllProviders(context)) {
  //     await provider.onLogin();
  //   }
  // }

  @override
  Future<void> onLogin() async {}

  @override
  Future<void> onLogout() async {}

  @override
  Future<void> onInit() async {}
}
