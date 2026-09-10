import 'package:collection/collection.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/extensions/sse_auto_refresh.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
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
  Future<TransactionState> build(TransactionFilter filter) async {
    // Listen for SSE data
    ref.listen(sseProvider, (prev, next) {
      final data = next.latestData;
      if (data?.event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(transactionApiProvider.future);
    final total = await api.transactionControllerGetTotal();

    String? apiCategory = filter.categoryId == "all" ? null : filter.categoryId;

    final initial = await api.transactionControllerGetByQuery(
      startIndex: 0,
      endIndex: pageSize,
      accountId: filter.accountId,
      category: apiCategory,
      description: filter.search,
      startDate: filter.dateRange?.start,
      endDate: filter.dateRange?.end,
      pending: filter.pending,
    );

    final transactions = initial ?? [];
    transactions.sort((a, b) => b.posted.compareTo(a.posted));

    return TransactionState(
      transactions: transactions,
      totalCount: total?.total ?? 0,
      hasReachedMax: transactions.length < pageSize,
    );
  }

  /// Fetches the next page of data matching the filter
  Future<void> fetchNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || current.hasReachedMax) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final api = await ref.read(transactionApiProvider.future);

      // Explicitly compute the next page boundary
      final int currentCount = current.transactions.length;
      final int startIndex = currentCount;
      final int endIndex = currentCount + pageSize;

      String? apiCategory = filter.categoryId == "all" ? null : filter.categoryId;

      final nextItems = await api.transactionControllerGetByQuery(
        startIndex: startIndex,
        endIndex: endIndex,
        accountId: filter.accountId,
        category: apiCategory,
        description: filter.search,
        startDate: filter.dateRange?.start,
        endDate: filter.dateRange?.end,
        pending: filter.pending,
      );

      if (nextItems == null || nextItems.isEmpty) {
        state = AsyncData(current.copyWith(isLoadingMore: false, hasReachedMax: true));
        return;
      }

      // Append without re-sorting to avoid shifting scroll offsets
      final existingIds = current.transactions.map((t) => t.id).toSet();
      final newUnique = nextItems.where((t) => !existingIds.contains(t.id)).toList();

      state = AsyncData(
        current.copyWith(
          transactions: [...current.transactions, ...newUnique],
          isLoadingMore: false,
          hasReachedMax: nextItems.length < pageSize,
        ),
      );
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

/// Provider to track transaction subscriptions
@Riverpod(keepAlive: true)
class TransactionSubscriptions extends _$TransactionSubscriptions {
  @override
  Future<List<TransactionSubscription>> build() async {
    final api = await ref.watch(transactionApiProvider.future);
    ref.refreshOnForceUpdate();
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

// Keep track of the active targeted calendar snapshot frame
final selectedCalendarMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Fetches a single transaction by ID, checking existing default provider state first.
@riverpod
Future<Transaction?> transactionById(Ref ref, String id) async {
  if (id.isEmpty) return null;

  // Listen for SSE auto-refresh updates
  ref.listen(sseProvider, (prev, next) {
    if (next.latestData?.event == SSEDataEventEnum.forceUpdate) {
      ref.invalidateSelf();
    }
  });

  // Check if we already have it loaded in the default filter state
  final masterState = ref.read(transactionsProvider(TransactionFilter.defaultFilter)).value;
  final localMatch = masterState?.transactions.firstWhereOrNull((t) => t.id == id);
  if (localMatch != null) return localMatch;

  // Otherwise, fetch directly from API
  try {
    final api = await ref.watch(transactionApiProvider.future);
    final results = await api.transactionControllerGetByQuery(id: id);
    if (results != null && results.isNotEmpty) {
      return results.first;
    }
  } catch (e) {
    LoggerProvider.error("Failed to fetch transaction $id: $e");
  }

  return null;
}
