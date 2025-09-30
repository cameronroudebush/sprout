import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/api/base.dart';
import 'package:sprout/transaction/models/category.dart';
import 'package:sprout/transaction/models/category_stats.dart';
import 'package:sprout/transaction/models/transaction.count.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/models/transaction.stats.dart';
import 'package:sprout/transaction/models/transaction.subscriptions.dart';
import 'package:sprout/transaction/models/transaction_rule.dart';

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
  Future<List<Transaction>> getTransactions(int startIndex, int endIndex, {Account? account}) async {
    final endpoint = "/transaction/get";
    final body = {'startIndex': startIndex, 'endIndex': endIndex, 'accountId': account?.id};
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

  /// Gets transaction rules
  Future<List<TransactionRule>> getTransactionRules() async {
    final endpoint = "/transaction/rule";
    final result = await client.get(endpoint) as List<dynamic>;
    return (result).map((e) => TransactionRule.fromJson(e)).toList();
  }

  /// Gets transaction rules
  Future<List<Category>> getCategories() async {
    final endpoint = "/transaction/categories";
    final result = await client.get(endpoint) as List<dynamic>;
    return (result).map((e) => Category.fromJson(e)).toList();
  }

  /// Gets the stats for our category information for the last N days
  Future<CategoryStats> getCategoryStats({int days = 30}) async {
    final endpoint = "/transaction/category/stats";
    final body = {'days': days};
    final result = await client.post(body, endpoint) as dynamic;
    return CategoryStats.fromJson(result);
  }

  /// Adds the given transaction rule via the API
  Future<TransactionRule> addTransactionRule(TransactionRule rule) async {
    final endpoint = "/transaction/rule/add";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return TransactionRule.fromJson(result);
  }

  /// Deletes the given transaction rule via the API
  Future<TransactionRule> deleteTransactionRule(TransactionRule rule) async {
    final endpoint = "/transaction/rule/delete";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return TransactionRule.fromJson(result);
  }

  /// Updates the given transaction rule via the API
  Future<TransactionRule> editTransactionRule(TransactionRule rule) async {
    final endpoint = "/transaction/rule/edit";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return TransactionRule.fromJson(result);
  }

  /// Updates the given transaction via the API
  Future<Transaction> editTransaction(Transaction t) async {
    final endpoint = "/transaction/edit";
    final body = t.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return Transaction.fromJson(result);
  }
}
