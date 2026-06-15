import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/transaction/models/transaction_state.dart';

part 'transaction_provider.g.dart';

/// Provider for the transaction api
@Riverpod(keepAlive: true)
Future<TransactionApi> transactionApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return TransactionApi(client);
}

@Riverpod(keepAlive: true)
class Transactions extends _$Transactions {
  static const int pageSize = 25;

  @override
  Future<TransactionState> build() async {
    // Listen for SSE data
    ref.listen(sseProvider, (prev, next) async {
      final data = next.latestData;
      final currentFilter = ref.read(transactionFilterStateProvider);
      if (data?.event == SSEDataEventEnum.forceUpdate) {
        // Fetch the filter
        await fetchFilteredPage(startIndex: 0, filter: currentFilter, reset: true);
        // Re-fetch the first page
        await fetchFilteredPage(
          startIndex: 0,
          // Do not include additional filters so we grab all initial data for the dashboard
        );
      }
    });

    state = AsyncData(TransactionState(
      transactions: [],
      totalCount: 0,
    ));

    await ref.watch(transactionApiProvider.future);
    await fetchFilteredPage(startIndex: 0);
    final updatedState = state.value!.copyWith(initialLoadComplete: true);
    state = AsyncData(updatedState);

    return updatedState;
  }

  /// Fetches data matching the given filter with the given index
  /// [reset] If we should reset the entire list. Warning, this
  ///   could cause issues where data might disappear more than you expect.
  Future<void> fetchFilteredPage({
    required int startIndex,
    TransactionFilter? filter,
    bool reset = false,
  }) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final api = await ref.read(transactionApiProvider.future);

      String? apiCategory = filter?.categoryId == "all" ? null : filter?.categoryId;

      final nextItems = await api.transactionControllerGetByQuery(
        startIndex: startIndex,
        endIndex: startIndex + pageSize,
        accountId: filter?.accountId,
        category: apiCategory,
        description: filter?.search,
        startDate: filter?.dateRange?.start,
        endDate: filter?.dateRange?.end,
        pending: filter?.pending,
      );

      if (nextItems != null) {
        final updatedList = reset
            ? nextItems
            : [...current.transactions, ...nextItems.where((t) => !current.transactions.any((e) => e.id == t.id))];

        state = AsyncData(
          current.copyWith(
            transactions: updatedList..sort((a, b) => b.posted.compareTo(a.posted)),
            isLoadingMore: false,
            hasReachedMax: nextItems.length < pageSize,
          ),
        );
      }
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<Transaction?> editTransaction(Transaction t) async {
    final api = await ref.read(transactionApiProvider.future);
    final updated = await api.transactionControllerEdit(t.id, t);
    await ref.read(unknownCategoryCountProvider().notifier).refresh();

    if (updated != null && state.value != null) {
      final newList = [...state.value!.transactions];
      final index = newList.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        newList[index] = updated;
        state = AsyncData(state.value!.copyWith(transactions: newList));
      }
    }
    return updated;
  }
}

// Global filter state
@riverpod
class TransactionFilterState extends _$TransactionFilterState {
  @override
  TransactionFilter build() => TransactionFilter();

  void update(TransactionFilter filter) => state = filter;
}

/// List of filtered transactions based on our state
@riverpod
List<Transaction> filteredTransactions(Ref ref) {
  final filter = ref.watch(transactionFilterStateProvider);
  final masterState = ref.watch(transactionsProvider).value;
  if (masterState == null) return [];

  return masterState.transactions.where((t) {
    // Filter by Account
    if (filter.accountId != null && t.accountId != filter.accountId) return false;

    // Filter by Search String
    if (filter.search.isNotEmpty) {
      if (!t.description.toLowerCase().contains(filter.search.toLowerCase())) return false;
    }

    // Filter by Category
    if (filter.categoryId != null && filter.categoryId != CategoryDropdown.fakeAllCategory.id) {
      if (filter.categoryId == "unknown") {
        if (t.categoryId != null) return false;
      } else if (t.categoryId != filter.categoryId) {
        return false;
      }
    }

    // Filter by Pending Status
    if (filter.pending != null && t.pending != filter.pending) {
      return false;
    }

    // Filter by Time Frame (Local check)
    if (filter.dateRange != null) {
      if (t.posted.isBefore(filter.dateRange!.start) || t.posted.isAfter(filter.dateRange!.end)) {
        return false;
      }
    }

    return true;
  }).toList();
}

/// Provider to track transaction subscriptions
@Riverpod(keepAlive: true)
class TransactionSubscriptions extends _$TransactionSubscriptions {
  @override
  Future<List<TransactionSubscription>> build() async {
    final api = await ref.watch(transactionApiProvider.future);
    return await api.transactionControllerSubscriptions() ?? [];
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

/// A provider that grabs transactions just for the given day
@riverpod
Future<List<Transaction>> transactionsForDay(Ref ref, DateTime day) async {
  final api = await ref.watch(transactionApiProvider.future);
  final startOfDay = DateTime(day.year, day.month, day.day, 0, 0, 0);
  final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
  final items = await api.transactionControllerGetByQuery(
    startIndex: 0,
    endIndex: 100,
    startDate: startOfDay,
    endDate: endOfDay,
  );
  return items ?? [];
}
