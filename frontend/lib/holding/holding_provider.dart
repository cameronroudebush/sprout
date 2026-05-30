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

/// Provides state to the holding history per holding id
@Riverpod(keepAlive: true)
class AccountHoldingHistory extends _$AccountHoldingHistory {
  @override
  Future<EntityHistory?> build(String holdingId) async {
    final api = await ref.watch(holdingApiProvider.future);
    return await api.holdingControllerGetSpecificHoldingHistory(holdingId);
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

/// A DataLoader style provider that batches requests from the UI
@Riverpod(keepAlive: true)
class BatchedLivePrices extends _$BatchedLivePrices {
  Timer? _refreshTimer;
  final Set<String> _pendingSymbols = {};
  bool _isFetching = false;

  @override
  Map<String, MarketIndexDto> build() {
    // Refresh all currently known symbols every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _refreshAll());
    ref.onDispose(() => _refreshTimer?.cancel());
    return {};
  }

  /// Called by the UI to register a symbol it needs
  void requestSymbol(String symbol) {
    if (state.containsKey(symbol) || _pendingSymbols.contains(symbol)) return;

    _pendingSymbols.add(symbol);
    _scheduleFetch();
  }

  void _scheduleFetch() {
    if (_isFetching) return;
    _isFetching = true;

    // Wait 50ms for the Flutter frame to finish mounting all HoldingRows
    Future.delayed(const Duration(milliseconds: 50), () async {
      if (_pendingSymbols.isEmpty) {
        _isFetching = false;
        return;
      }

      final symbolsToFetch = _pendingSymbols.toList();
      _pendingSymbols.clear();

      try {
        // Use ref.read to prevent reactive rebuilds!
        final api = await ref.read(holdingApiProvider.future);
        final results = await api.holdingControllerGetLivePrices(symbolsToFetch);

        if (results != null) {
          final newState = Map<String, MarketIndexDto>.from(state);
          for (final data in results) {
            newState[data.symbol] = data;
          }
          state = newState;
        }
      } finally {
        _isFetching = false;
        // If more widgets asked for symbols while we were fetching, go again
        if (_pendingSymbols.isNotEmpty) _scheduleFetch();
      }
    });
  }

  Future<void> _refreshAll() async {
    if (state.isEmpty) return;
    try {
      final api = await ref.read(holdingApiProvider.future);
      final results = await api.holdingControllerGetLivePrices(state.keys.toList());
      if (results != null) {
        final newState = Map<String, MarketIndexDto>.from(state);
        for (final data in results) {
          newState[data.symbol] = data;
        }
        state = newState;
      }
    } catch (_) {}
  }
}

/// Provides the 7-day historical performance timeline for major market indicies.
/// Updates automatically on a rolling 1-hour interval matching the backend's cache policy.
@Riverpod(keepAlive: true)
class MajorIndicesTimeline extends _$MajorIndicesTimeline {
  Timer? _refreshTimer;

  @override
  Future<List<MajorIndexTimelineDto>> build() async {
    // Refresh history timelines every hour to match backend cache lifetimes.
    _refreshTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => ref.invalidateSelf(),
    );

    ref.onDispose(() => _refreshTimer?.cancel());
    final api = await ref.watch(holdingApiProvider.future);
    return await api.holdingControllerGetMajorIndicesTimeline() ?? [];
  }
}
