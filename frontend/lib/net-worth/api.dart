import 'package:sprout/core/api/base.dart';
import 'package:sprout/net-worth/models/net.worth.ot.dart';

/// Class that provides callable endpoints for the NetWorth information
class NetWorthAPI extends BaseAPI {
  NetWorthAPI(super.client);

  /// Returns the net worth data for all current accounts
  Future<double> getNetWorth() async {
    final endpoint = "/transaction/net-worth/get";
    return await client.get(endpoint) as double;
  }

  /// Returns net worth over time
  Future<HistoricalNetWorth> getHistoricalNetWorth() async {
    final endpoint = "/transaction/net-worth/get/ot";
    dynamic result = await client.get(endpoint);
    return HistoricalNetWorth.fromJson(result);
  }
}
