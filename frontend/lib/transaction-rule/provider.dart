import 'package:sprout/core/provider/base.dart';
import 'package:sprout/transaction-rule/api.dart';
import 'package:sprout/transaction/models/transaction_rule.dart';

/// Class that provides the store of current transactions
class TransactionRuleProvider extends BaseProvider<TransactionRuleAPI> {
  // Data store
  List<TransactionRule> _rules = [];
  bool _transactionRulesRunning = false;

  // Public getters
  List<TransactionRule> get rules => _rules;
  bool get transactionRulesRunning => _transactionRulesRunning;

  TransactionRuleProvider(super.api);

  Future<List<TransactionRule>> populateTransactionRules() async {
    return _rules = await api.get();
  }

  Future<TransactionRule> add(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final addedRule = await api.add(rule);
    _rules.add(addedRule);
    notifyListeners();
    return addedRule;
  }

  Future<TransactionRule> delete(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final deletedRule = await api.delete(rule);
    _rules.removeWhere((r) => r.id == deletedRule.id);
    notifyListeners();
    return deletedRule;
  }

  Future<TransactionRule> edit(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final updatedRule = await api.edit(rule);
    final index = _rules.indexWhere((r) => r.id == updatedRule.id);
    if (index != -1) _rules[index] = updatedRule;
    notifyListeners();
    return updatedRule;
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateTransactionRules();
    isLoading = false;
    _transactionRulesRunning = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _rules = [];
    _transactionRulesRunning = false;
    notifyListeners();
  }
}
