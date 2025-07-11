import 'package:sprout/api/client.dart';

/// Class that provides callable endpoints for the transaction information
class TransactionAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  TransactionAPI(this.client);

  /// Returns the accounts
  Future<double> getNetWorth() async {
    final endpoint = "/transaction/net-worth/get";

    try {
      double result = await client.get(endpoint) as double;
      return result;
    } catch (e) {
      return 0;
    }
  }
}
