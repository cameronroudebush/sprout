import 'package:sprout/core/api/base.dart';
import 'package:sprout/holding/models/holding.dart';
import 'package:sprout/net-worth/models/entity.history.dart';

/// Class that provides callable endpoints for the holdings of each account
class HoldingAPI extends BaseAPI {
  HoldingAPI(super.client);

  /// Returns the holdings for the current user
  Future<List<Holding>> getHoldings() async {
    final endpoint = "/holding/get";
    List result = await client.get(endpoint) as List<dynamic>;
    return (result).map((e) => Holding.fromJson(e)).toList();
  }

  /// Returns the holdings over time values for the current user
  Future<Map<String, List<EntityHistory>>> getOT() async {
    final endpoint = "/holding/history/all";
    dynamic result = await client.get(endpoint) as dynamic;
    return Map<String, List<dynamic>>.from(
      result as Map,
    ).map((key, value) => MapEntry(key, value.map((e) => EntityHistory.fromJson(e)).toList()));
  }
}
