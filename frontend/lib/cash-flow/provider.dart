import 'package:sprout/account/models/account.dart';
import 'package:sprout/cash-flow/api.dart';
import 'package:sprout/cash-flow/models/cash_flow_stats.dart';
import 'package:sprout/charts/sankey/models/data.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of cash flow data
class CashFlowProvider extends BaseProvider<CashFlowAPI> {
  // Data store
  final Map<String, SankeyData> _sankeyDataCache = {};
  final Map<String, CashFlowStats> _statsCache = {};

  // Public getters
  SankeyData? getSankeyData(int year, int month, {int? day, Account? account}) {
    return _sankeyDataCache[_generateCacheKey(year, month, day, account)];
  }

  CashFlowStats? getStatsData(int year, int month, {int? day, Account? account}) {
    return _statsCache[_generateCacheKey(year, month, day, account)];
  }

  CashFlowProvider(super.api);

  /// Populates the sankey data for all accounts
  Future<SankeyData> getSankey(int year, int month, {int? day, Account? account}) async {
    final cacheKey = _generateCacheKey(year, month, day, account);
    final data = await api.get(year, month, day: day, account: account);
    _sankeyDataCache[cacheKey] = data;
    notifyListeners();
    return data;
  }

  /// Populates cash flow stats for the given query
  Future<CashFlowStats> getStats(int year, int month, {int? day, Account? account}) async {
    final cacheKey = _generateCacheKey(year, month, day, account);
    final data = await api.getStats(year, month, day: day, account: account);
    _statsCache[cacheKey] = data;
    notifyListeners();
    return data;
  }

  /// Generates the key for the map based on the query
  String _generateCacheKey(int year, int month, int? day, Account? account) {
    return '$year-$month-${day ?? 'all'}-${account?.id ?? 'all'}';
  }

  @override
  Future<void> updateData() async {
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _sankeyDataCache.clear();
    notifyListeners();
  }
}
