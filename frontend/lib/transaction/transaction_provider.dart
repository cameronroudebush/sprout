import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/shared/api/base_api.dart';
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
    final api = await ref.watch(transactionApiProvider.future);
    final total = await api.transactionControllerGetTotal();
    final initial = await api.transactionControllerGetByQuery(startIndex: 0, endIndex: pageSize);

    return TransactionState(transactions: initial ?? [], totalCount: total?.total ?? 0);
  }

  /// Fetches data matching the given filter with the given index
  Future<void> fetchFilteredPage({required int startIndex, String? accountId, String? catId, String? search}) async {
    final current = state.value;
    if (current == null || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final api = await ref.read(transactionApiProvider.future);

      // Slight category adjustment
      String? apiCategory = catId == "all" ? null : catId;

      final nextItems = await api.transactionControllerGetByQuery(
        startIndex: startIndex,
        endIndex: startIndex + pageSize,
        accountId: accountId,
        category: apiCategory,
        description: search,
      );

      if (nextItems != null) {
        final existingIds = current.transactions.map((t) => t.id).toSet();
        final newUnique = nextItems.where((t) => !existingIds.contains(t.id)).toList();

        // If we got back fewer items than we asked for, we've reached the end
        final reachedMax = nextItems.length < pageSize;

        state = AsyncData(
          current.copyWith(
            transactions: [...current.transactions, ...newUnique]..sort((a, b) => b.posted.compareTo(a.posted)),
            isLoadingMore: false,
            hasReachedMax: reachedMax,
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

/// List of filtered transactions based on our state
@riverpod
List<Transaction> filteredTransactions(Ref ref, {String? accountId, String? categoryId, String? search}) {
  // Watch the master list
  final masterState = ref.watch(transactionsProvider).value;
  if (masterState == null) return [];

  return masterState.transactions.where((t) {
    // Filter by Account
    if (accountId != null && t.account.id != accountId) return false;

    // Filter by Search String
    if (search != null && search.isNotEmpty) {
      if (!t.description.toLowerCase().contains(search.toLowerCase())) return false;
    }

    // Filter by Category
    if (categoryId != null && categoryId != CategoryDropdown.fakeAllCategory.id) {
      // If filtering for null in DB
      if (categoryId == "unknown") return t.category == null;
      // Normal category match
      if (t.category?.id != categoryId) return false;
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
