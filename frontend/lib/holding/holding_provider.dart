import 'dart:async';

import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current holding information for accounts
class HoldingProvider extends BaseProvider<HoldingApi> {
  HoldingProvider(super.api);

  /// Given an account, grabs holdings and holdings over time and returns that information
  Future<(List<Holding>?, List<EntityHistory>?)> getHoldingDataForAccount(Account account) async {
    setLoadingStatus(true);
    final holdings = await api.holdingControllerGetHoldings(account.id);
    final holdingsHistory = await api.holdingControllerGetHoldingHistory(account.id);
    setLoadingStatus(false);
    return (holdings, holdingsHistory);
  }
}
