import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current net worth information
class NetWorthProvider extends BaseProvider<NetWorthApi> {
  // Data store
  num? _netWorth;
  EntityHistory? _historicalNetWorth;
  List<EntityHistory>? _historicalAccountData;

  // Public getters
  num? get netWorth => _netWorth;
  EntityHistory? get historicalNetWorth => _historicalNetWorth;
  List<EntityHistory>? get historicalAccountData => _historicalAccountData;

  NetWorthProvider(super.api);

  /// Populates the single current net worth value.
  Future<num?> populateNetWorth() async {
    return _netWorth = await api.netWorthControllerGetNetWorth();
  }

  /// Populates the net worth overtime flow.
  Future<EntityHistory?> populateHistoricalNetWorth() async {
    return _historicalNetWorth = await api.netWorthControllerGetNetWorthOT();
  }

  /// Populates the net worth overtime flow.
  Future<List<EntityHistory>?> populateHistoricalAccountData() async {
    return _historicalAccountData = await api.netWorthControllerGetNetWorthByAccounts();
  }

  @override
  Future<void> cleanupData() async {
    _netWorth = null;
    _historicalNetWorth = null;
    _historicalAccountData = [];
    notifyListeners();
  }
}
