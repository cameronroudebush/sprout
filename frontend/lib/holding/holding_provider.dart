import 'dart:async';

import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current holding information for accounts
class HoldingProvider extends BaseProvider<HoldingApi> {
  // Data store. Both are separated by account ID
  final Map<String, List<Holding>> _holdings = {};
  final Map<String, List<EntityHistory>> _holdingsHistory = {};

  /// Split by holdingID
  final Map<String, List<HistoricalDataPoint>> _holdingsTimeline = {};

  // Public getters
  List<HistoricalDataPoint>? getHoldingTimelineData(String holdingId) => _holdingsTimeline[holdingId];

  HoldingProvider(super.api);

  /// Given an account, grabs holdings and holdings over time and returns that information
  Future<(List<Holding>?, List<EntityHistory>?)> populateDataForAccount(Account account) async {
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

    return (_holdings[account.id], _holdingsHistory[account.id]);
  }

  /// Given an account, returns the holdings and holdings over time without populating more
  (List<Holding>?, List<EntityHistory>?) getHoldingDataForAccount(Account account) {
    return (_holdings[account.id], _holdingsHistory[account.id]);
  }

  /// Populates the timeline data for a specific given holding
  Future<List<HistoricalDataPoint>?> populateHoldingTimelineData(String holdingId) async {
    return populateAndSetIfChanged(
      () => api.holdingControllerGetHoldingTimeline(holdingId),
      getHoldingTimelineData(holdingId),
      (newValue) {
        if (newValue != null) _holdingsTimeline[holdingId] = newValue;
      },
    );
  }
}
