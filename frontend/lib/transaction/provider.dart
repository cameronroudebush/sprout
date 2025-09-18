import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/transaction/api.dart';
import 'package:sprout/transaction/models/transaction.count.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/models/transaction.stats.dart';
import 'package:sprout/transaction/models/transaction.subscriptions.dart';

/// Class that provides the store of current transactions
class TransactionProvider extends BaseProvider<TransactionAPI> {
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

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateTotalTransactionCount();
    await populateStats();
    await populateTransactions(0, 20); // Grab some to start
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
