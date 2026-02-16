import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current net worth information
class NetWorthProvider extends BaseProvider<NetWorthApi> {
  // Data store
  TotalNetWorthDTO? _total;
  List<EntityHistory>? _historicalAccountData;
  final Map<String, List<HistoricalDataPoint>> _accountTimelineData = {};

  // Public getters
  TotalNetWorthDTO? get total => _total;
  List<EntityHistory>? get historicalAccountData => _historicalAccountData;
  List<HistoricalDataPoint>? getAccountTimelineData(String accountId) => _accountTimelineData[accountId];

  NetWorthProvider(super.api);

  /// Populates the overarching net worth over time data for all our accounts
  Future<TotalNetWorthDTO?> populateTotal() async {
    return populateAndSetIfChanged(api.netWorthControllerGetNetWorthTotal, _total, (newValue) => _total = newValue);
  }

  /// Populate how our accounts have performed
  Future<List<EntityHistory>?> populateHistoricalAccountData() async {
    return populateAndSetIfChanged(
      () => api.netWorthControllerGetNetWorthByAccounts(),
      _historicalAccountData,
      (newValue) => _historicalAccountData = newValue,
    );
  }

  /// Populates the timeline data for display for our given account
  Future<List<HistoricalDataPoint>?> populateAccountTimelineData(String accountId) async {
    return populateAndSetIfChanged(
      () => api.netWorthControllerGetNetWorthTimelineAccount(accountId),
      getAccountTimelineData(accountId),
      (newValue) {
        if (newValue != null) _accountTimelineData[accountId] = newValue;
      },
    );
  }

  @override
  Future<void> cleanupData() async {
    _total = null;
    _historicalAccountData = null;
    notifyListeners();
  }
}
