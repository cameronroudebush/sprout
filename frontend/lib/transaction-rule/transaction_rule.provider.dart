import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current transactions
class TransactionRuleProvider extends BaseProvider<TransactionRuleApi> {
  // Data store
  List<TransactionRule> _rules = [];
  bool _transactionRulesRunning = false;

  // Public getters
  List<TransactionRule> get rules => _rules;
  bool get transactionRulesRunning => _transactionRulesRunning;

  TransactionRuleProvider(super.api);

  Future<List<TransactionRule>> populateTransactionRules() async {
    isLoading = true;
    final rulesFromApi = (await api.transactionRuleControllerGet()) ?? [];
    _rules = List<TransactionRule>.from(rulesFromApi);
    isLoading = false;
    notifyListeners();
    return _rules;
  }

  Future<TransactionRule?> add(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final addedRule = await api.transactionRuleControllerCreate(rule);
    if (addedRule != null) _rules.add(addedRule);
    notifyListeners();
    return addedRule;
  }

  Future<TransactionRule> delete(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    await api.transactionRuleControllerDelete(rule.id);
    _rules.removeWhere((r) => r.id == rule.id);
    notifyListeners();
    return rule;
  }

  Future<TransactionRule> edit(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final updatedRule = (await api.transactionRuleControllerEdit(rule.id, rule))!;
    final index = _rules.indexWhere((r) => r.id == updatedRule.id);
    if (index != -1) _rules[index] = updatedRule;
    notifyListeners();
    return updatedRule;
  }

  @override
  Future<void> cleanupData() async {
    _rules = [];
    _transactionRulesRunning = false;
    notifyListeners();
  }
}
