import 'dart:async';

import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current account information
class AccountProvider extends BaseProvider<AccountApi> {
  // Data store
  List<Account> _linkedAccounts = [];
  StreamSubscription<SSEData>? _sub;
  bool manualSyncIsRunning = false;

  // Getters to not allow editing the internal store
  List<Account> get linkedAccounts => _linkedAccounts;

  AccountProvider(super.api);

  Future<List<Account>> populateLinkedAccounts() async {
    setLoadingStatus(true);
    final apiLinkedAccounts = List<Account>.from(await api.accountControllerGetAccounts() ?? []);
    setLoadingStatus(false);
    return _linkedAccounts = apiLinkedAccounts;
  }

  /// Uses the API and edits the given account
  Future<Account> edit(Account a) async {
    notifyListeners();
    final updated = (await api.accountControllerEdit(a.id, AccountEditRequest(name: a.name, subType: a.subType)))!;
    final index = _linkedAccounts.indexWhere((r) => r.id == updated.id);
    if (index != -1) _linkedAccounts[index] = updated;
    notifyListeners();
    return updated;
  }

  /// Tells the API to manually run an account refresh
  Future<void> manualSync() async {
    manualSyncIsRunning = true;
    notifyListeners();
    await api.accountControllerManualSync();
  }

  @override
  Future<void> cleanupData() async {
    _linkedAccounts = [];
    notifyListeners();
    _sub?.cancel();
  }
}
