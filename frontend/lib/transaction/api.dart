import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/api/base.dart';
import 'package:sprout/transaction/models/transaction.count.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/models/transaction.stats.dart';
import 'package:sprout/transaction/models/transaction.subscriptions.dart';

/// Class that provides callable endpoints for the transaction information
class TransactionAPI extends BaseAPI {
  TransactionAPI(super.client);

  /// Returns a count of the total number of transactions for this user
  Future<TotalTransactions> getTransactionCount() async {
    final endpoint = "/transaction/count";
    dynamic result = await client.get(endpoint) as dynamic;
    return TotalTransactions.fromJson(result);
  }

  /// Returns the transactions between the indexes given
  Future<List<Transaction>> getTransactions({
    int? startIndex,
    int? endIndex,
    Account? account,
    dynamic category,
    String? description,
    DateTime? date,
  }) async {
    final endpoint = "/transaction/get";
    final body = {
      'startIndex': startIndex,
      'endIndex': endIndex,
      'accountId': account?.id,
      'category': category,
      'description': description,
      'date': date?.millisecondsSinceEpoch,
    };
    List result = await client.post(body, endpoint) as List<dynamic>;
    return (result).map((e) => Transaction.fromJson(e)).toList();
  }

  Future<List<Transaction>> getTransactionsByDescription(String description, {Account? account}) async {
    final endpoint = "/transaction/get/by/description";
    final body = {'description': description, 'accountId': account?.id};
    List result = await client.post(body, endpoint) as List<dynamic>;
    return (result).map((e) => Transaction.fromJson(e)).toList();
  }

  /// Gets transaction stats for the last N days
  Future<TransactionStats> getStats({int days = 30}) async {
    final endpoint = "/transaction/stats";
    final body = {'days': days};
    return TransactionStats.fromJson(await client.post(body, endpoint) as dynamic);
  }

  /// Gets subscriptions information
  Future<List<TransactionSubscription>> getSubscriptions() async {
    final endpoint = "/transaction/subscriptions";
    final result = await client.get(endpoint) as List<dynamic>;
    return (result).map((e) => TransactionSubscription.fromJson(e)).toList();
  }

  /// Updates the given transaction via the API
  Future<Transaction> editTransaction(Transaction t) async {
    final endpoint = "/transaction/edit";
    final body = t.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return Transaction.fromJson(result);
  }
}
