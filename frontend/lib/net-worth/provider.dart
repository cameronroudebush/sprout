import 'package:flutter/material.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/net-worth/api.dart';
import 'package:sprout/net-worth/models/net.worth.ot.dart';

/// Class that provides the store of current net worth information
class NetWorthProvider with ChangeNotifier {
  final NetWorthAPI _netWorthAPI;
  final AuthProvider? _authProvider;
  final AccountProvider? _accountProvider;

  // Data store
  double? _netWorth;
  HistoricalNetWorth? _historicalNetWorth;

  // Getters to not allow editing the internal store
  double? get netWorth => _netWorth;
  HistoricalNetWorth? get historicalNetWorth => _historicalNetWorth;

  NetWorthProvider(this._netWorthAPI, this._authProvider, this._accountProvider) {
    if (_authProvider != null &&
        _authProvider.isLoggedIn &&
        _accountProvider != null &&
        _accountProvider.linkedAccounts.isNotEmpty) {
      populateNetWorth();
      populateHistoricalNetWorth();
    }
  }

  /// Populates the single current net worth value.
  Future<double?> populateNetWorth() async {
    final result = await _netWorthAPI.getNetWorth();
    _netWorth = result;
    notifyListeners();
    return _netWorth;
  }

  /// Populates the net worth overtime flow.
  Future<HistoricalNetWorth?> populateHistoricalNetWorth() async {
    final result = await _netWorthAPI.getHistoricalNetWorth();
    _historicalNetWorth = result;
    notifyListeners();
    return _historicalNetWorth;
  }
}
