import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';

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
  // Automatically refresh on SSE forceUpdate
  ref.listen(sseProvider, (prev, next) {
    final event = next.latestData?.event;
    if (event == SSEDataEventEnum.forceUpdate) {
      ref.invalidateSelf();
    }
  });

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
  final api = await ref.watch(cashFlowApiProvider.future);
  return await api.cashFlowControllerGetStats(year, month: month, day: day, accountId: accountId);
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
