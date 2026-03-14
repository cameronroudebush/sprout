import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
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
  static const int pageSize = 20;

  @override
  Future<TransactionState> build() async {
    ref.listen(sseProvider, (prev, next) {
      final event = next.latestData?.event;
      if (event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(transactionApiProvider.future);
    final total = await api.transactionControllerGetTotal();

    /// Grab our initial transactions. Utilizes [pageSize]
    final initial = await api.transactionControllerGetByQuery(startIndex: 0, endIndex: pageSize);

    return TransactionState(transactions: initial ?? [], totalCount: total?.total ?? 0);
  }

  /// Fetches the next page and appends it to the list
  Future<void> fetchNextPage({String? accountId, String? category, String? description, DateTime? date}) async {
    if (state.value == null || state.value!.isLoadingMore) return;
    if (state.value!.transactions.length >= state.value!.totalCount) return;

    state = AsyncData(state.value!.copyWith(isLoadingMore: true));

    try {
      final api = await ref.read(transactionApiProvider.future);
      final nextItems = await api.transactionControllerGetByQuery(
        startIndex: state.value!.transactions.length,
        endIndex: state.value!.transactions.length + pageSize,
        accountId: accountId,
        category: category,
        description: description,
        date: date,
      );

      if (nextItems != null) {
        final currentIds = state.value!.transactions.map((t) => t.id).toSet();
        final filtered = nextItems.where((t) => !currentIds.contains(t.id)).toList();

        final newList = [...state.value!.transactions, ...filtered]..sort((a, b) => b.posted.compareTo(a.posted));

        state = AsyncData(state.value!.copyWith(transactions: newList, isLoadingMore: false));
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<Transaction?> editTransaction(Transaction t) async {
    final api = await ref.read(transactionApiProvider.future);
    final updated = await api.transactionControllerEdit(t.id, t);

    if (updated != null && state.value != null) {
      final index = state.value!.transactions.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        final newList = [...state.value!.transactions];
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
    return await api.transactionControllerSubscriptions() ?? [];
  }

  Future<void> refresh() async => ref.invalidateSelf();
}
