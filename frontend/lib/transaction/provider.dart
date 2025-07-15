import 'package:flutter/material.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/transaction/api.dart';
import 'package:sprout/transaction/models/transaction.dart';

/// Class that provides the store of current transactions
class TransactionProvider with ChangeNotifier {
  final TransactionAPI _transactionAPI;
  final AuthProvider? _authProvider;
  final AccountProvider? _accountProvider;

  // Data store
  int _totalTransactionCount = 0;
  List<Transaction> _transactions = [];

  // Getters to not allow editing the internal store
  List<Transaction> get transactions => _transactions;
  int get totalTransactionCount => _totalTransactionCount;
  bool get isLoading => _transactions.isEmpty;
  int get rowsPerPage => 5;

  TransactionProvider(this._transactionAPI, this._authProvider, this._accountProvider) {
    if (_authProvider != null &&
        _authProvider.isLoggedIn &&
        _accountProvider != null &&
        _accountProvider.linkedAccounts.isNotEmpty) {
      populateTotalTransactionCount();
      // Grab our most recent 20
      populateTransactions(0, rowsPerPage);
    }
  }

  Future<int> populateTotalTransactionCount() async {
    final count = await _transactionAPI.getTransactionCount();
    _totalTransactionCount = count;
    notifyListeners();
    return _totalTransactionCount;
  }

  Future<List<Transaction>> populateTransactions(int startIndex, int endIndex) async {
    final newTransactions = await _transactionAPI.getTransactions(startIndex, endIndex);

    // Combine new transactions with existing ones, removing duplicates
    final Set<String> existingTransactionIds = _transactions.map((t) => t.id).toSet();
    for (var newTransaction in newTransactions) {
      if (!existingTransactionIds.contains(newTransaction.id)) {
        _transactions.add(newTransaction);
      }
    }

    notifyListeners();
    return _transactions;
  }
}
