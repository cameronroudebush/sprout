import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';

part 'net_worth_provider.g.dart';

/// Future that provides an authenticated net worth api
@Riverpod(keepAlive: true)
Future<NetWorthApi> netWorthApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return NetWorthApi(client);
}

/// Defines the riverpod for the net worth state
@Riverpod(keepAlive: true)
class TotalNetWorth extends _$TotalNetWorth {
  @override
  Future<TotalNetWorthDTO?> build() async {
    // Automatically refresh on SSE events
    ref.listen(sseProvider, (prev, next) {
      if (next.value?.event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(netWorthApiProvider.future);
    return await api.netWorthControllerGetNetWorthTotal();
  }
}

/// Defines the historical account data
@Riverpod(keepAlive: true)
class HistoricalAccountData extends _$HistoricalAccountData {
  @override
  Future<List<EntityHistory>?> build() async {
    final api = await ref.watch(netWorthApiProvider.future);
    return await api.netWorthControllerGetNetWorthByAccounts();
  }

  /// Manual refresh if needed from UI pull-to-refresh
  Future<void> refresh() async => ref.invalidateSelf();
}

/// Defines the overall account timeline
@Riverpod(keepAlive: true)
class AccountTimeline extends _$AccountTimeline {
  @override
  Future<List<HistoricalDataPoint>?> build(String accountId) async {
    final api = await ref.watch(netWorthApiProvider.future);
    return await api.netWorthControllerGetNetWorthTimelineAccount(accountId);
  }
}
