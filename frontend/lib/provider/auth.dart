import 'package:flutter/material.dart';
import 'package:sprout/api/user.dart';
import 'package:sprout/model/user.dart';

class AuthProvider with ChangeNotifier {
  final UserAPI _userAPI;
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  // Constructor to check initial login status
  AuthProvider(this._userAPI) {
    _checkInitialLoginStatus();
  }

  Future<void> _checkInitialLoginStatus() async {
    User? user = await _userAPI.loginWithJWT(null);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<User?> login(String username, String password) async {
    User? user = await _userAPI.loginWithPassword(username, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    await _userAPI.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
