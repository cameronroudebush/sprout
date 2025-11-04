import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current transactions
class TransactionProvider extends BaseProvider<TransactionApi> {
  /// How many transactions we should initially pull
  static final initialTransactionCount = 20;
  // Data store
  TotalTransactions? _totalTransactions;
  List<Transaction> _transactions = [];
  List<TransactionSubscription> _subscriptions = [];

  // Public getters
  List<Transaction> get transactions => _transactions;
  TotalTransactions? get totalTransactions => _totalTransactions;
  List<TransactionSubscription> get subscriptions => _subscriptions;

  TransactionProvider(super.api);

  Future<TotalTransactions?> populateTotalTransactionCount() async {
    return _totalTransactions = await api.transactionControllerGetTotal();
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
  Future<List<Transaction>?> populateTransactions({
    int? startIndex,
    int? endIndex,
    bool shouldNotify = true,
    Account? account,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    final newTransactions = await api.transactionControllerGetByQuery(
      startIndex: startIndex,
      endIndex: endIndex,
      accountId: account?.id,
      category: category,
      description: description,
      date: date,
    );
    if (newTransactions != null) _addNewTransactions(newTransactions);
    if (shouldNotify) notifyListeners();
    return newTransactions;
  }

  /// Populates subscription information built from transactions
  Future<List<TransactionSubscription>?> populateSubscriptions(bool showLoaders) async {
    final shouldSetLoadingStats = _subscriptions.isEmpty || showLoaders;
    if (shouldSetLoadingStats) setLoadingStatus(true);
    await populateAndSetIfChanged(
      api.transactionControllerSubscriptions,
      _subscriptions,
      (newValue) => _subscriptions = newValue ?? [],
    );
    if (shouldSetLoadingStats) setLoadingStatus(false);
    return _subscriptions;
  }

  /// Utilizes the API to edit the given transaction and updates the data store
  Future<Transaction> editTransaction(Transaction t) async {
    final updatedTransaction = (await api.transactionControllerEdit(t.id, t))!;
    final index = _transactions.indexWhere((r) => r.id == updatedTransaction.id);
    if (index != -1) _transactions[index] = updatedTransaction;
    notifyListeners();
    return updatedTransaction;
  }

  /// Wipes all currently loaded transaction data. You'll normally do this if you're about to request more.
  void wipeData() {
    _totalTransactions = null;
    _transactions = [];
    _subscriptions = [];
  }

  @override
  Future<void> cleanupData() async {
    _totalTransactions = null;
    _transactions = [];
    _subscriptions = [];
    notifyListeners();
  }
}
