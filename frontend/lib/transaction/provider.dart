import 'package:sprout/account/models/account.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/transaction/api.dart';
import 'package:sprout/transaction/models/transaction.count.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/models/transaction.stats.dart';
import 'package:sprout/transaction/models/transaction.subscriptions.dart';

/// Class that provides the store of current transactions
class TransactionProvider extends BaseProvider<TransactionAPI> {
  /// How many transactions we should initially pull
  static final initialTransactionCount = 20;
  // Data store
  TotalTransactions? _totalTransactions;
  TransactionStats? _transactionStats;
  List<Transaction> _transactions = [];
  List<TransactionSubscription> _subscriptions = [];

  // Public getters
  List<Transaction> get transactions => _transactions;
  TotalTransactions? get totalTransactions => _totalTransactions;
  TransactionStats? get transactionStats => _transactionStats;
  List<TransactionSubscription> get subscriptions => _subscriptions;

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

  /// Populates transactions based on the parameters given
  Future<List<Transaction>> populateTransactions(
    int startIndex,
    int endIndex, {
    bool shouldNotify = true,
    Account? account,
    dynamic category,
    String? description,
  }) async {
    final newTransactions = await api.getTransactions(
      startIndex,
      endIndex,
      account: account,
      category: category,
      description: description,
    );
    _addNewTransactions(newTransactions);
    if (shouldNotify) notifyListeners();
    return _transactions;
  }

  Future<TransactionStats?> populateStats() async {
    return _transactionStats = await api.getStats();
  }

  /// Populates subscription information built from transactions
  Future<List<TransactionSubscription>> populateSubscriptions() async {
    return _subscriptions = await api.getSubscriptions();
  }

  /// Utilizes the API to edit the given transaction and updates the data store
  Future<Transaction> editTransaction(Transaction t) async {
    final updatedTransaction = await api.editTransaction(t);
    final index = _transactions.indexWhere((r) => r.id == updatedTransaction.id);
    if (index != -1) _transactions[index] = updatedTransaction;
    // Update category info
    await ServiceLocator.get<CategoryProvider>().populateCategoryStats();
    notifyListeners();
    return updatedTransaction;
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    _transactions = []; // Forcible reset so we need to update all transactions
    notifyListeners();
    await populateTotalTransactionCount();
    await populateStats();
    await populateTransactions(0, initialTransactionCount, shouldNotify: false);
    await populateSubscriptions();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _transactionStats = null;
    _totalTransactions = null;
    _transactions = [];
    notifyListeners();
  }
}
