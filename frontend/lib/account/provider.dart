import 'dart:async';

import 'package:sprout/account/api.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/model/rest.request.dart';

/// Class that provides the store of current account information
class AccountProvider extends BaseProvider<AccountAPI> {
  // Data store
  List<Account> _linkedAccounts = [];
  StreamSubscription<SSEBody<dynamic>>? _sub;
  bool manualSyncIsRunning = false;

  // Getters to not allow editing the internal store
  List<Account> get linkedAccounts => _linkedAccounts;

  AccountProvider(super.api);

  Future<List<Account>> populateLinkedAccounts() async {
    return _linkedAccounts = await api.getAccounts();
  }

  /// Tells the API to manually run an account refresh
  Future<void> manualSync() async {
    manualSyncIsRunning = true;
    notifyListeners();
    await api.runManualSync();
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateLinkedAccounts();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _linkedAccounts = [];
    notifyListeners();
    _sub?.cancel();
  }
}
