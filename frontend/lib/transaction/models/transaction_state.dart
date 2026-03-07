import 'package:sprout/api/api.dart';

/// The transactions state that tracks our available transactions in the frontend
class TransactionState {
  final List<Transaction> transactions;
  final num totalCount;
  final bool isLoadingMore;

  TransactionState({required this.transactions, required this.totalCount, this.isLoadingMore = false});

  TransactionState copyWith({List<Transaction>? transactions, num? totalCount, bool? isLoadingMore}) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
