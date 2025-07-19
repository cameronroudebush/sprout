import 'package:sprout/core/provider/base.dart';
import 'package:sprout/net-worth/api.dart';
import 'package:sprout/net-worth/models/net.worth.ot.dart';

/// Class that provides the store of current net worth information
class NetWorthProvider extends BaseProvider<NetWorthAPI> {
  // Data store
  double? _netWorth;
  HistoricalNetWorth? _historicalNetWorth;

  // Public getters
  double? get netWorth => _netWorth;
  HistoricalNetWorth? get historicalNetWorth => _historicalNetWorth;
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

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await _populateNetWorth();
    await _populateHistoricalNetWorth();
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
