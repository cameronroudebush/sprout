import 'package:sprout/core/provider/base.dart';
import 'package:sprout/transaction/api.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/models/transaction.stats.dart';

/// Class that provides the store of current transactions
class TransactionProvider extends BaseProvider<TransactionAPI> {
  // Data store
  int _totalTransactionCount = 0;
  TransactionStats? _transactionStats;
  List<Transaction> _transactions = [];

  // Public getters
  List<Transaction> get transactions => _transactions;
  int get totalTransactionCount => _totalTransactionCount;
  int get rowsPerPage => 5;
  TransactionStats? get transactionStats => _transactionStats;
  bool isLoading = false;

  TransactionProvider(super.api);

  Future<int> populateTotalTransactionCount() async {
    return _totalTransactionCount = await api.getTransactionCount();
  }

  Future<List<Transaction>> populateTransactions(int startIndex, int endIndex) async {
    final newTransactions = await api.getTransactions(startIndex, endIndex);
    // Combine new transactions with existing ones, removing duplicates
    final Set<String> existingTransactionIds = _transactions.map((t) => t.id).toSet();
    for (var newTransaction in newTransactions) {
      if (!existingTransactionIds.contains(newTransaction.id)) {
        _transactions.add(newTransaction);
      }
    }
    return _transactions;
  }

  Future<TransactionStats?> populateStats() async {
    return _transactionStats = await api.getStats();
  }

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onLogin() async {
    isLoading = true;
    notifyListeners();
    await populateTotalTransactionCount();
    await populateStats();
    await populateTransactions(0, rowsPerPage); // Grab most recent
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> onLogout() async {}
}
