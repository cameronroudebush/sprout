import 'package:sprout/core/provider/base.dart';
import 'package:sprout/net-worth/api.dart';
import 'package:sprout/net-worth/models/entity.history.dart';

/// Class that provides the store of current net worth information
class NetWorthProvider extends BaseProvider<NetWorthAPI> {
  // Data store
  double? _netWorth;
  EntityHistory? _historicalNetWorth;
  List<EntityHistory>? _historicalAccountData;

  // Public getters
  double? get netWorth => _netWorth;
  EntityHistory? get historicalNetWorth => _historicalNetWorth;
  List<EntityHistory>? get historicalAccountData => _historicalAccountData;
  bool isLoading = false;

  NetWorthProvider(super.api);

  /// Populates the single current net worth value.
  Future<double?> _populateNetWorth() async {
    return _netWorth = await api.getNetWorth();
  }

  /// Populates the net worth overtime flow.
  Future<EntityHistory?> _populateHistoricalNetWorth() async {
    return _historicalNetWorth = await api.getHistoricalNetWorth();
  }

  /// Populates the net worth overtime flow.
  Future<List<EntityHistory>> _populateHistoricalAccountData() async {
    return _historicalAccountData = await api.getNetWorthByAccounts();
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await _populateNetWorth();
    await _populateHistoricalNetWorth();
    await _populateHistoricalAccountData();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _netWorth = null;
    _historicalNetWorth = null;
    notifyListeners();
  }
}
