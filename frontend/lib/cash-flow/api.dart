import 'package:sprout/account/models/account.dart';
import 'package:sprout/cash-flow/models/cash_flow_stats.dart';
import 'package:sprout/charts/sankey/models/data.dart';
import 'package:sprout/core/api/base.dart';

/// Class that provides callable endpoints for cash flow information
class CashFlowAPI extends BaseAPI {
  CashFlowAPI(super.client);

  /// Gets sankey information for the given query
  Future<SankeyData> get(int year, int month, {int? day, Account? account}) async {
    final endpoint = "/cash-flow/get";
    final body = {'year': year, 'month': month, 'day': day, 'account': account};
    final result = await client.post(body, endpoint) as dynamic;
    return SankeyData.fromJson(result);
  }

  /// Gets cash flow stats for the given query
  Future<CashFlowStats> getStats(int year, int month, {int? day, Account? account}) async {
    final endpoint = "/cash-flow/stats";
    final body = {'year': year, 'month': month, 'day': day, 'account': account};
    final result = await client.post(body, endpoint) as dynamic;
    return CashFlowStats.fromJson(result);
  }
}
