import 'package:sprout/api/api.dart';

/// The transactions state that tracks our available transactions in the frontend
class TransactionState {
  final List<Transaction> transactions;
  final num totalCount;
  final bool isLoadingMore;
  final bool hasReachedMax;

  TransactionState({
    required this.transactions,
    required this.totalCount,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    num? totalCount,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
