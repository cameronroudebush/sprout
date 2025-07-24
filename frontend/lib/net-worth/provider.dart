import 'package:sprout/core/provider/base.dart';
import 'package:sprout/net-worth/api.dart';
import 'package:sprout/net-worth/models/net.worth.ot.dart';

/// Class that provides the store of current net worth information
class NetWorthProvider extends BaseProvider<NetWorthAPI> {
  // Data store
  double? _netWorth;
  HistoricalNetWorth? _historicalNetWorth;
  List<HistoricalNetWorth>? _historicalAccountData;

  // Public getters
  double? get netWorth => _netWorth;
  HistoricalNetWorth? get historicalNetWorth => _historicalNetWorth;
  List<HistoricalNetWorth>? get historicalAccountData => _historicalAccountData;
  bool isLoading = false;

  NetWorthProvider(super.api);

  /// Populates the single current net worth value.
  Future<double?> _populateNetWorth() async {
    return _netWorth = await api.getNetWorth();
  }

  /// Populates the net worth overtime flow.
  Future<HistoricalNetWorth?> _populateHistoricalNetWorth() async {
    return _historicalNetWorth = await api.getHistoricalNetWorth();
  }

  /// Populates the net worth overtime flow.
  Future<List<HistoricalNetWorth>> _populateHistoricalAccountData() async {
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
