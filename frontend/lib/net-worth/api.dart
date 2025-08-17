import 'package:sprout/core/api/base.dart';
import 'package:sprout/net-worth/models/entity.history.dart';

/// Class that provides callable endpoints for the NetWorth information
class NetWorthAPI extends BaseAPI {
  NetWorthAPI(super.client);

  /// Returns the net worth data for all current accounts
  Future<double> getNetWorth() async {
    final endpoint = "/transaction/net-worth/get";
    final result = await client.get(endpoint);
    return (result as num).toDouble();
  }

  /// Returns net worth over time
  Future<EntityHistory> getHistoricalNetWorth() async {
    final endpoint = "/transaction/net-worth/get/ot";
    dynamic result = await client.get(endpoint);
    return EntityHistory.fromJson(result);
  }

  /// Returns net worth over time
  Future<List<EntityHistory>> getNetWorthByAccounts() async {
    final endpoint = "/transaction/net-worth/get/by/accounts";
    final List<dynamic> result = await client.get(endpoint) as dynamic;
    return result.map((e) => EntityHistory.fromJson(e)).toList();
  }
}
