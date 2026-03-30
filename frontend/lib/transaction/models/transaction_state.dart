import 'package:flutter/material.dart';
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

/// A state utilized by the transaction provider
class TransactionFilter {
  String? accountId;
  String? categoryId;
  String search;
  DateTimeRange? dateRange;
  bool? pending;

  TransactionFilter({
    this.accountId,
    this.categoryId,
    this.search = '',
    this.dateRange,
    this.pending,
  });

  TransactionFilter copyWith({
    String? accountId,
    String? categoryId,
    String? search,
    DateTimeRange? dateRange,
    bool? pending,
  }) {
    return TransactionFilter(
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      search: search ?? this.search,
      dateRange: dateRange ?? this.dateRange,
      pending: pending ?? this.pending,
    );
  }
}
