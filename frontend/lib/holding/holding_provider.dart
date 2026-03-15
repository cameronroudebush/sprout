import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';

part "holding_provider.g.dart";

/// Provides the API for the holding info
@Riverpod(keepAlive: true)
Future<HoldingApi> holdingApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return HoldingApi(client);
}

/// Provides state to the account holdings info
@Riverpod(keepAlive: true)
class AccountHoldings extends _$AccountHoldings {
  @override
  Future<List<Holding>> build(String accountId) async {
    // Auto-refresh when an SSE update for this account arrives
    ref.listen(sseProvider, (prev, next) {
      final event = next.latestData?.event;
      if (event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(holdingApiProvider.future);
    return await api.holdingControllerGetHoldings(accountId) ?? [];
  }
}

/// Provides state to the account holding history per account id
@Riverpod(keepAlive: true)
class AccountHoldingsHistory extends _$AccountHoldingsHistory {
  @override
  Future<List<EntityHistory>> build(String accountId) async {
    final api = await ref.watch(holdingApiProvider.future);
    return await api.holdingControllerGetHoldingHistory(accountId) ?? [];
  }
}

/// Provides state to the account holding timelines
@Riverpod(keepAlive: true)
class HoldingTimeline extends _$HoldingTimeline {
  @override
  Future<List<HistoricalDataPoint>> build(String holdingId) async {
    final api = await ref.watch(holdingApiProvider.future);
    return await api.holdingControllerGetHoldingTimeline(holdingId) ?? [];
  }
}

/// Provides information for the major indices for holding content
@Riverpod(keepAlive: true)
class MajorIndices extends _$MajorIndices {
  Timer? _timer;

  @override
  Future<List<MarketIndexDto>> build() async {
    // Refresh every 5 minutes. Anything less than that will be the same as the backend caches in 5 minute increments
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => ref.invalidateSelf());

    ref.onDispose(() => _timer?.cancel());

    final api = await ref.watch(holdingApiProvider.future);
    return await api.holdingControllerGetLiveMajor() ?? [];
  }
}

/// Riverpod that provides live price of a stock utilizing the backend API
@Riverpod(keepAlive: true)
class LivePrice extends _$LivePrice {
  Timer? _timer;

  @override
  Future<MarketIndexDto?> build(String symbol) async {
    // Refresh cycle to match backend cache
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => ref.invalidateSelf());
    ref.onDispose(() => _timer?.cancel());
    final api = await ref.watch(holdingApiProvider.future);
    final results = await api.holdingControllerGetLivePrices([symbol]);

    return results?.firstOrNull;
  }
}
