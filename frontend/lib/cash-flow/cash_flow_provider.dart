import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/extensions/sse_auto_refresh.dart';

part 'cash_flow_provider.g.dart';

/// Authenticated API to cash flow
@Riverpod(keepAlive: true)
Future<CashFlowApi> cashFlowApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return CashFlowApi(client);
}

/// Sankey data based on time
@Riverpod(keepAlive: true)
Future<SankeyData> sankeyData(Ref ref, {required int year, int? month, int? day, String? accountId}) async {
  ref.refreshOnForceUpdate();
  final api = await ref.watch(cashFlowApiProvider.future);
  final data = await api.cashFlowControllerGetSankey(year, month: month, day: day, accountId: accountId);

  if (data == null) throw Exception("Failed to load Sankey data");

  return SankeyData(
    nodes: data.nodes,
    colors: data.colors as dynamic,
    links: data.links
        .map((e) => SankeyLink(source_: e.source_, target: e.target, value: e.value, description: e.description))
        .toList(),
  );
}

/// State for cash flow stats
@Riverpod(keepAlive: true)
Future<CashFlowStats?> cashFlowStats(Ref ref, {required int year, int? month, int? day, String? accountId}) async {
  ref.refreshOnForceUpdate();
  final api = await ref.watch(cashFlowApiProvider.future);
  return await api.cashFlowControllerGetStats(year, month: month, day: day, accountId: accountId);
}

/// State for cash flow trends
@Riverpod(keepAlive: true)
Future<List<CashFlowTrendStats>?> cashFlowTrend(Ref ref, int months) async {
  ref.refreshOnForceUpdate();
  final api = await ref.watch(cashFlowApiProvider.future);
  return await api.cashFlowControllerGetTrend(months);
}

/// Monthly spending state
@Riverpod(keepAlive: true)
class MonthlySpending extends _$MonthlySpending {
  @override
  Future<CashFlowSpending?> build({int months = 4, int? categories}) async {
    // Default categories based on platform if not provided
    final categoryCount = categories ?? (kIsWeb ? 5 : 2);

    final api = await ref.watch(cashFlowApiProvider.future);
    return await api.cashFlowControllerGetSpending(months, categoryCount);
  }

  /// Explicitly trigger a refresh if needed
  Future<void> refresh() async => ref.invalidateSelf();
}

@Riverpod(keepAlive: true)
class CashFlowComparisonTimeline extends _$CashFlowComparisonTimeline {
  @override
  Future<CashFlowComparisonDTO?> build({
    required int baselineYear,
    int? baselineMonth,
    required int targetYear,
    int? targetMonth,
  }) async {
    ref.refreshOnForceUpdate();
    final api = await ref.watch(cashFlowApiProvider.future);

    return await api.cashFlowControllerGetComparisonTimeline(
      baselineYear,
      targetYear,
      baselineMonth: baselineMonth,
      targetMonth: targetMonth,
    );
  }
}

/// Live dynamic provider tracking discrete daily spending aggregates over a given month canvas
@Riverpod(keepAlive: true)
Future<Map<int, double>> dailySpending(Ref ref, {required int month, required int year}) async {
  ref.refreshOnForceUpdate();
  final api = await ref.watch(cashFlowApiProvider.future);
  final DailySpendingCalendarResponseDTO? response = await api.cashFlowControllerGetDailyCalendarSpending(
    year,
    month,
  );
  if (response == null || response.spending.isEmpty) return {};
  return {for (final item in response.spending) item.day.toInt(): item.amount.toDouble()};
}
