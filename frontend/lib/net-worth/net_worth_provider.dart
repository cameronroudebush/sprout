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
    return populateAndSetIfChanged(api.netWorthControllerGetNetWorth, _netWorth, (newValue) => _netWorth = newValue);
  }

  /// Populates the net worth overtime flow.
  Future<EntityHistory?> populateHistoricalNetWorth() async {
    return populateAndSetIfChanged(
      api.netWorthControllerGetNetWorthOT,
      _historicalNetWorth,
      (newValue) => _historicalNetWorth = newValue,
    );
  }

  /// Populates the net worth overtime flow.
  Future<List<EntityHistory>?> populateHistoricalAccountData() async {
    return populateAndSetIfChanged(
      api.netWorthControllerGetNetWorthByAccounts,
      _historicalAccountData,
      (newValue) => _historicalAccountData = newValue,
    );
  }

  /// Loads any necessary data for the home page, only updating if the content is different
  Future<void> loadHomePageData(bool showLoaders) async {
    final shouldSetLoadingStats =
        _netWorth == null || _historicalNetWorth == null || _historicalAccountData == null || showLoaders;
    if (shouldSetLoadingStats) setLoadingStatus(true);
    // Grab all the data at once
    await Future.wait([populateNetWorth(), populateHistoricalNetWorth(), populateHistoricalAccountData()]);
    if (shouldSetLoadingStats) setLoadingStatus(false);
  }

  @override
  Future<void> cleanupData() async {
    _netWorth = null;
    _historicalNetWorth = null;
    _historicalAccountData = null;
    notifyListeners();
  }
}
