import 'package:sprout/core/api/base.dart';
import 'package:sprout/transaction-rule/models/transaction_rule.dart';

/// Class that provides callable endpoints for the transaction rules
class TransactionRuleAPI extends BaseAPI {
  TransactionRuleAPI(super.client);

  /// Gets transaction rules
  Future<List<TransactionRule>> get() async {
    final endpoint = "/transaction/rule";
    final result = await client.get(endpoint) as List<dynamic>;
    return (result).map((e) => TransactionRule.fromJson(e)).toList();
  }

  /// Adds the given transaction rule via the API
  Future<TransactionRule> add(TransactionRule rule) async {
    final endpoint = "/transaction/rule/add";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return TransactionRule.fromJson(result);
  }

  /// Deletes the given transaction rule via the API
  Future<TransactionRule> delete(TransactionRule rule) async {
    final endpoint = "/transaction/rule/delete";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return TransactionRule.fromJson(result);
  }

  /// Updates the given transaction rule via the API
  Future<TransactionRule> edit(TransactionRule rule) async {
    final endpoint = "/transaction/rule/edit";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return TransactionRule.fromJson(result);
  }
}
