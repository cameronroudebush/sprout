import 'package:flutter/material.dart';
import 'package:sprout/account/api.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/auth/provider.dart';

/// Class that provides the store of current account information
class AccountProvider with ChangeNotifier {
  final AccountAPI _accountAPI;
  final AuthProvider? _authProvider;

  // Data store
  List<Account> _linkedAccounts = [];

  // Getters to not allow editing the internal store
  List<Account> get linkedAccounts => _linkedAccounts;

  AccountProvider(this._accountAPI, this._authProvider) {
    if (_authProvider != null && _authProvider.isLoggedIn) {
      populateLinkedAccounts();
    }
  }

  Future<List<Account>> populateLinkedAccounts() async {
    final result = await _accountAPI.getAccounts();
    _linkedAccounts = result;
    notifyListeners();
    return _linkedAccounts;
  }
}
