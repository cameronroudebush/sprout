import 'package:sprout/api/api.dart' hide SankeyData, SankeyLink;
import 'package:sprout/charts/sankey/models/data.dart';
import 'package:sprout/charts/sankey/models/link.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of cash flow data
class CashFlowProvider extends BaseProvider<CashFlowApi> {
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
    final data = (await api.cashFlowControllerGetSankey(year, month: month, day: day, accountId: account?.id))!;

    final convertedData = SankeyData(
      nodes: data.nodes,
      colors: data.colors as dynamic,
      links: data.links
          .map((e) => SankeyLink(source: e.source_, target: e.target, value: e.value, description: e.description))
          .toList(),
    );
    _sankeyDataCache[cacheKey] = convertedData;
    notifyListeners();
    return convertedData;
  }

  /// Populates cash flow stats for the given query
  Future<CashFlowStats?> getStats(int year, int month, {int? day, Account? account}) async {
    final cacheKey = _generateCacheKey(year, month, day, account);
    final data = await api.cashFlowControllerGetStats(year, month: month, day: day, accountId: account?.id);
    if (data != null) _statsCache[cacheKey] = data;
    notifyListeners();
    return data;
  }

  /// Generates the key for the map based on the query
  String _generateCacheKey(int year, int month, int? day, Account? account) {
    return '$year-$month-${day ?? 'all'}-${account?.id ?? 'all'}';
  }

  @override
  Future<void> cleanupData() async {
    _sankeyDataCache.clear();
    notifyListeners();
  }
}
