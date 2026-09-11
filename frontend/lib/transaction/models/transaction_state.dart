import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// The transactions state that tracks our available transactions in the frontend
class TransactionState {
  final List<Transaction> transactions;
  final num totalCount;
  final bool isLoadingMore;
  final bool hasReachedMax;

  TransactionState(
      {required this.transactions, required this.totalCount, this.isLoadingMore = false, this.hasReachedMax = false});

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
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }
}

/// A state utilized by the transaction provider
@immutable
class TransactionFilter {
  final String? accountId;
  final String? categoryId;
  final String search;
  final DateTimeRange? dateRange;
  final bool? pending;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.search = '',
    this.dateRange,
    this.pending,
  });

  /// Default static key for baseline/unfiltered lookups
  static const defaultFilter = TransactionFilter();

  TransactionFilter copyWith({
    String? accountId,
    String? categoryId,
    String? search,
    DateTimeRange? dateRange,
    bool? pending,
    bool clearPending = false,
  }) {
    return TransactionFilter(
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      search: search ?? this.search,
      dateRange: dateRange ?? this.dateRange,
      pending: clearPending ? null : (pending ?? this.pending),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionFilter &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.search == search &&
        other.pending == pending &&
        other.dateRange?.start == dateRange?.start &&
        other.dateRange?.end == dateRange?.end;
  }

  @override
  int get hashCode => Object.hash(
        accountId,
        categoryId,
        search,
        pending,
        dateRange?.start,
        dateRange?.end,
      );
}
