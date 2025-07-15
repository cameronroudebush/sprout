import 'package:flutter/material.dart';
import 'package:sprout/auth/api.dart';
import 'package:sprout/model/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthAPI _authAPI;
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  // Constructor to check initial login status
  AuthProvider(this._authAPI) {
    _checkInitialLoginStatus();
  }

  Future<void> _checkInitialLoginStatus() async {
    User? user = await _authAPI.loginWithJWT(null);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<User?> login(String username, String password) async {
    User? user = await _authAPI.loginWithPassword(username, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    await _authAPI.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
