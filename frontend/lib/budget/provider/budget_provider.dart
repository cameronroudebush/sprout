import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/extensions/sse_auto_refresh.dart';

/// Authenticated API provider for BudgetApi
final budgetApiProvider = FutureProvider<BudgetApi>((ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return BudgetApi(client);
});

/// Provider fetching all user budgets
final allBudgetsProvider = FutureProvider<List<Budget>>((ref) async {
  ref.refreshOnForceUpdate();
  final api = await ref.watch(budgetApiProvider.future);
  final budgets = await api.budgetControllerGetAllBudgets();
  return budgets ?? [];
});

/// Provider fetching monthly budget overview breakdown
final budgetOverviewProvider = FutureProvider.family<BudgetOverviewResponseDto?, ({int? year, int? month})>((ref, args) async {
  ref.refreshOnForceUpdate();
  final api = await ref.watch(budgetApiProvider.future);
  return await api.budgetControllerGetBudgetOverview(year: args.year, month: args.month);
});

/// Provider fetching historical budget performance
final budgetHistoryProvider = FutureProvider.family<BudgetHistoryResponseDto?, ({int months, String? categoryId})>((ref, args) async {
  ref.refreshOnForceUpdate();
  final api = await ref.watch(budgetApiProvider.future);
  return await api.budgetControllerGetBudgetHistory(months: args.months, categoryId: args.categoryId);
});

/// Provider for budget actions
final budgetActionsProvider = Provider<BudgetActions>((ref) => BudgetActions(ref));

class BudgetActions {
  final Ref ref;

  BudgetActions(this.ref);

  Future<Budget?> createBudget(String categoryId, double amount) async {
    final api = await ref.read(budgetApiProvider.future);
    final dto = CreateBudgetDto(categoryId: categoryId, amount: amount);
    final result = await api.budgetControllerCreateBudget(dto);
    ref.invalidate(allBudgetsProvider);
    ref.invalidate(budgetOverviewProvider);
    ref.invalidate(budgetHistoryProvider);
    return result;
  }

  Future<Budget?> updateBudget(String budgetId, double amount) async {
    final api = await ref.read(budgetApiProvider.future);
    final dto = UpdateBudgetDto(amount: amount);
    final result = await api.budgetControllerUpdateBudget(budgetId, dto);
    ref.invalidate(allBudgetsProvider);
    ref.invalidate(budgetOverviewProvider);
    ref.invalidate(budgetHistoryProvider);
    return result;
  }

  Future<void> deleteBudget(String budgetId) async {
    final api = await ref.read(budgetApiProvider.future);
    await api.budgetControllerDeleteBudget(budgetId);
    ref.invalidate(allBudgetsProvider);
    ref.invalidate(budgetOverviewProvider);
    ref.invalidate(budgetHistoryProvider);
  }
}
