import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/transaction/api.dart';
import 'package:sprout/transaction/models/category.dart';
import 'package:sprout/transaction/models/category_stats.dart';
import 'package:sprout/transaction/models/transaction.count.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/models/transaction.stats.dart';
import 'package:sprout/transaction/models/transaction.subscriptions.dart';
import 'package:sprout/transaction/models/transaction_rule.dart';

/// Class that provides the store of current transactions
class TransactionProvider extends BaseProvider<TransactionAPI> {
  // Data store
  TotalTransactions? _totalTransactions;
  TransactionStats? _transactionStats;
  List<Transaction> _transactions = [];
  List<TransactionSubscription> _subscriptions = [];
  List<TransactionRule> _rules = [];
  List<Category> _categories = [];
  CategoryStats? _categoryStats;
  bool _transactionRulesRunning = false;

  // Public getters
  List<Transaction> get transactions => _transactions;
  TotalTransactions? get totalTransactions => _totalTransactions;
  TransactionStats? get transactionStats => _transactionStats;
  List<TransactionSubscription> get subscriptions => _subscriptions;
  List<TransactionRule> get rules => _rules;
  List<Category> get categories => _categories;
  CategoryStats? get categoryStats => _categoryStats;
  bool get transactionRulesRunning => _transactionRulesRunning;

  TransactionProvider(super.api);

  Future<TotalTransactions> populateTotalTransactionCount() async {
    return _totalTransactions = await api.getTransactionCount();
  }

  /// Adds new transactions to our global list and filters duplicates out
  void _addNewTransactions(List<Transaction> newTransactions) {
    // Combine new transactions with existing ones, removing duplicates
    final Set<String> existingTransactionIds = _transactions.map((t) => t.id).toSet();
    for (var newTransaction in newTransactions) {
      if (!existingTransactionIds.contains(newTransaction.id)) {
        _transactions.add(newTransaction);
      }
    }
    _transactions.sort((a, b) => b.posted.compareTo(a.posted));
  }

  Future<List<Transaction>> populateTransactions(
    int startIndex,
    int endIndex, {
    bool shouldNotify = false,
    Account? account,
  }) async {
    final newTransactions = await api.getTransactions(startIndex, endIndex, account: account);
    _addNewTransactions(newTransactions);
    if (shouldNotify) notifyListeners();
    return _transactions;
  }

  Future<TransactionStats?> populateStats() async {
    return _transactionStats = await api.getStats();
  }

  Future<List<TransactionRule>> populateTransactionRules() async {
    return _rules = await api.getTransactionRules();
  }

  /// Same as @populateTransactions but now does it with a specific search term
  Future<List<Transaction>> populateTransactionsWithSearch(
    String description, {
    bool shouldNotify = true,
    Account? account,
  }) async {
    final newTransactions = await api.getTransactionsByDescription(description);
    _addNewTransactions(newTransactions);
    if (shouldNotify) notifyListeners();
    return _transactions;
  }

  /// Populates subscription information built from transactions
  Future<List<TransactionSubscription>> populateSubscriptions() async {
    return _subscriptions = await api.getSubscriptions();
  }

  Future<List<Category>> populateCategories() async {
    return _categories = await api.getCategories();
  }

  Future<CategoryStats> populateCategoryStats() async {
    return _categoryStats = await api.getCategoryStats();
  }

  Future<TransactionRule> addTransactionRule(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final addedRule = await api.addTransactionRule(rule);
    _rules.add(addedRule);
    notifyListeners();
    return addedRule;
  }

  Future<TransactionRule> deleteTransactionRule(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final deletedRule = await api.deleteTransactionRule(rule);
    _rules.removeWhere((r) => r.id == deletedRule.id);
    notifyListeners();
    return deletedRule;
  }

  Future<TransactionRule> editTransactionRule(TransactionRule rule) async {
    _transactionRulesRunning = true;
    notifyListeners();
    final updatedRule = await api.editTransactionRule(rule);
    final index = _rules.indexWhere((r) => r.id == updatedRule.id);
    if (index != -1) _rules[index] = updatedRule;
    notifyListeners();
    return updatedRule;
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateTotalTransactionCount();
    await populateStats();
    await populateTransactions(0, 20); // Grab some to start
    await populateSubscriptions();
    await populateTransactionRules();
    await populateCategories();
    await populateCategoryStats();
    isLoading = false;
    _transactionRulesRunning = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _transactionStats = null;
    _totalTransactions = null;
    _transactions = [];
    _rules = [];
    _categories = [];
    _categoryStats = null;
    notifyListeners();
  }
}
