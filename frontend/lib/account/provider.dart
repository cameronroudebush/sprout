import 'dart:async';

import 'package:sprout/account/api.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/model/rest.request.dart';

/// Class that provides the store of current account information
class AccountProvider extends BaseProvider<AccountAPI> {
  // Data store
  List<Account> _linkedAccounts = [];
  StreamSubscription<SSEBody<dynamic>>? _sub;

  // Getters to not allow editing the internal store
  List<Account> get linkedAccounts => _linkedAccounts;

  AccountProvider(super.api);

  Future<List<Account>> populateLinkedAccounts() async {
    _linkedAccounts = await api.getAccounts();
    notifyListeners();
    return _linkedAccounts;
  }

  @override
  Future<void> onInit() async {
    final sseProvider = ServiceLocator.get<SSEProvider>();
    // Listen for sync requests
    _sub = sseProvider.onEvent.listen((data) {
      if (data.queue == "sync") {
        BaseProvider.updateAllData(showSnackbar: true);
      }
    });
  }

  /// Tells the API to manually run an account refresh
  Future<void> manualSync() async {
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
