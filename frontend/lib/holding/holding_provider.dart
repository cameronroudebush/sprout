import 'dart:async';

import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current holding information for accounts
class HoldingProvider extends BaseProvider<HoldingApi> {
  // Data store
  final Map<String, List<Holding>> _holdings = {};
  final Map<String, List<EntityHistory>> _holdingsHistory = {};

  HoldingProvider(super.api);

  /// Given an account, grabs holdings and holdings over time and returns that information
  Future<(List<Holding>?, List<EntityHistory>?)> populateDataForAccount(Account account, bool showLoaders) async {
    final shouldSetLoadingStats = (_holdings[account.id]?.isEmpty ?? true) || showLoaders;
    if (shouldSetLoadingStats) setLoadingStatus(true);

    await Future.wait([
      populateAndSetIfChanged(
        () => api.holdingControllerGetHoldings(account.id),
        _holdings[account.id],
        (newValue) => _holdings[account.id] = newValue ?? [],
      ),
      populateAndSetIfChanged(
        () => api.holdingControllerGetHoldingHistory(account.id),
        _holdingsHistory[account.id],
        (newValue) => _holdingsHistory[account.id] = newValue ?? [],
      ),
    ]);

    if (shouldSetLoadingStats) setLoadingStatus(false);
    return (_holdings[account.id], _holdingsHistory[account.id]);
  }

  /// Given an account, returns the holdings and holdings over time without populating more
  (List<Holding>?, List<EntityHistory>?) getHoldingDataForAccount(Account account) {
    return (_holdings[account.id], _holdingsHistory[account.id]);
  }
}
