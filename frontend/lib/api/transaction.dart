import 'package:sprout/api/client.dart';
import 'package:sprout/model/net.worth.dart';

/// Class that provides callable endpoints for the transaction information
class TransactionAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  TransactionAPI(this.client);

  /// Returns the net worth data for all current accounts
  Future<double> getNetWorth() async {
    final endpoint = "/transaction/net-worth/get";

    try {
      double result = await client.get(endpoint) as double;
      return result;
    } catch (e) {
      return 0;
    }
  }

  /// Returns net worth over time
  Future<NetWorthOverTime> getNetWorthOT() async {
    final endpoint = "/transaction/net-worth/get/ot";
    dynamic result = await client.get(endpoint);
    return NetWorthOverTime.fromJson(result);
  }
}
