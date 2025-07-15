import 'package:sprout/core/api/client.dart';
import 'package:sprout/transaction/models/transaction.dart';

/// Class that provides callable endpoints for the transaction information
class TransactionAPI {
  RESTClient client;
  TransactionAPI(this.client);

  /// Returns a count of the total number of transactions for this user
  Future<int> getTransactionCount() async {
    final endpoint = "/transaction/count";
    dynamic result = await client.get(endpoint) as dynamic;
    return result as int;
  }

  /// Returns the transactions between the indexes given
  Future<List<Transaction>> getTransactions(int startIndex, int endIndex) async {
    final endpoint = "/transaction/get";
    final body = {'startIndex': startIndex, 'endIndex': endIndex};
    List result = await client.post(body, endpoint) as List<dynamic>;
    return (result).map((e) => Transaction.fromJson(e)).toList();
  }
}
