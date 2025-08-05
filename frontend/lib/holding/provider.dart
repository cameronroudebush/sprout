import 'dart:async';

import 'package:sprout/core/provider/base.dart';
import 'package:sprout/holding/api.dart';
import 'package:sprout/holding/models/holding.dart';

/// Class that provides the store of current holding information for accounts
class HoldingProvider extends BaseProvider<HoldingAPI> {
  // Data store
  List<Holding> _holdings = [];

  // Getters to not allow editing the internal store
  List<Holding> get holdings => _holdings;

  HoldingProvider(super.api);

  Future<List<Holding>> populateHoldings() async {
    return _holdings = await api.getHoldings();
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateHoldings();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _holdings = [];
    notifyListeners();
  }
}
