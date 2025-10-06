import 'dart:async';

import 'package:sprout/core/provider/base.dart';
import 'package:sprout/holding/api.dart';
import 'package:sprout/holding/models/holding.dart';
import 'package:sprout/net-worth/models/entity.history.dart';

/// Class that provides the store of current holding information for accounts
class HoldingProvider extends BaseProvider<HoldingAPI> {
  // Data store
  List<Holding> _holdings = [];
  Map<String, List<EntityHistory>> _holdingsOT = {};

  // Getters to not allow editing the internal store
  List<Holding> get holdings => _holdings;
  Map<String, List<EntityHistory>> get holdingsOT => _holdingsOT;

  HoldingProvider(super.api);

  Future<List<Holding>> populateHoldings() async {
    return _holdings = await api.getHoldings();
  }

  Future<Map<String, List<EntityHistory>>> populateHoldingsOT() async {
    return _holdingsOT = await api.getOT();
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateHoldings();
    await populateHoldingsOT();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _holdings = [];
    notifyListeners();
  }
}
