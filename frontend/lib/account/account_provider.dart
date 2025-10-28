import 'dart:async';

import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';

/// Class that provides the store of current account information
class AccountProvider extends BaseProvider<AccountApi> {
  // Data store
  List<Account> _linkedAccounts = [];

  /// Tracks if we are actively running a sync that was trigger by this user
  bool manualSyncIsRunning = false;

  // Getters to not allow editing the internal store
  List<Account> get linkedAccounts => _linkedAccounts;

  AccountProvider(super.api);

  /// Populates link account information for the initial load and handles double checking if the data has actually changed
  Future<List<Account>> populateLinkedAccounts(bool showLoaders) async {
    final shouldSetLoadingStats = _linkedAccounts.isEmpty || showLoaders;
    if (shouldSetLoadingStats) setLoadingStatus(true);
    await populateAndSetIfChanged(
      api.accountControllerGetAccounts,
      _linkedAccounts,
      (newValue) => _linkedAccounts = newValue ?? [],
    );
    if (shouldSetLoadingStats) setLoadingStatus(false);
    return _linkedAccounts;
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
    try {
      manualSyncIsRunning = true;
      notifyListeners();
      await api.accountControllerManualSync();
    } catch (e) {
      SnackbarProvider.openWithAPIException(e);
      manualSyncIsRunning = false;
      notifyListeners();
    }
  }

  @override
  Future<void> cleanupData() async {
    _linkedAccounts = [];
    notifyListeners();
  }

  @override
  Future<void> onSSE(SSEData data) async {
    await super.onSSE(data);
    // Reset status of manual sync button
    if (data.event == SSEDataEventEnum.sync_) {
      manualSyncIsRunning = false;
      notifyListeners();
      final configProvider = ServiceLocator.get<ConfigProvider>();
      if (configProvider.config != null) {
        configProvider.config!.lastSchedulerRun = ModelSync.fromJson(data.payload);
      }
    }
  }
}
