import 'package:sprout/core/api/base.dart';
import 'package:sprout/holding/models/holding.dart';

/// Class that provides callable endpoints for the holdings of each account
class HoldingAPI extends BaseAPI {
  HoldingAPI(super.client);

  /// Returns the holdings for the current user
  Future<List<Holding>> getHoldings() async {
    final endpoint = "/holding/get";
    List result = await client.get(endpoint) as List<dynamic>;
    return (result).map((e) => Holding.fromJson(e)).toList();
  }
}
