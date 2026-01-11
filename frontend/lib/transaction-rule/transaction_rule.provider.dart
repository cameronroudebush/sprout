import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/transaction-rule/dialog/rule_manual.dart';

/// Class that provides the store of current transactions
class TransactionRuleProvider extends BaseProvider<TransactionRuleApi> {
  // Data store
  List<TransactionRule> _rules = [];
  bool _transactionRulesRunning = false;

  // Public getters
  List<TransactionRule> get rules => _rules;
  bool get transactionRulesRunning => _transactionRulesRunning;

  TransactionRuleProvider(super.api);

  /// Populates transaction rules from the API and performs updates if there are changes.
  Future<List<TransactionRule>> populateTransactionRules() async {
    await populateAndSetIfChanged(api.transactionRuleControllerGet, _rules, (newValue) => _rules = newValue ?? []);
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
    _transactionRulesRunning = false;
    notifyListeners();
    return updatedRule;
  }

  /// Opens a dialog that asks the user if they want to manually refresh their transactions
  ///   based on their rules.
  openManualRefreshDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => TransactionRuleManualDialog());
  }

  /// Manually runs a refresh to update all transaction rules
  manualRefresh({force = false}) async {
    _transactionRulesRunning = true;
    notifyListeners();
    await api.transactionRuleControllerApplyRules(force: force);
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
