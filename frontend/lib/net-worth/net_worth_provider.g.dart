// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Future that provides an authenticated net worth api

@ProviderFor(netWorthApi)
const netWorthApiProvider = NetWorthApiProvider._();

/// Future that provides an authenticated net worth api

final class NetWorthApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetWorthApi>,
          NetWorthApi,
          FutureOr<NetWorthApi>
        >
    with $FutureModifier<NetWorthApi>, $FutureProvider<NetWorthApi> {
  /// Future that provides an authenticated net worth api
  const NetWorthApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'netWorthApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$netWorthApiHash();

  @$internal
  @override
  $FutureProviderElement<NetWorthApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetWorthApi> create(Ref ref) {
    return netWorthApi(ref);
  }
}

String _$netWorthApiHash() => r'29d4de716ec1fac061c34db54bd8ab4a6a6f4e6f';

/// Defines the riverpod for the net worth state

@ProviderFor(TotalNetWorth)
const totalNetWorthProvider = TotalNetWorthProvider._();

/// Defines the riverpod for the net worth state
final class TotalNetWorthProvider
    extends $AsyncNotifierProvider<TotalNetWorth, TotalNetWorthDTO?> {
  /// Defines the riverpod for the net worth state
  const TotalNetWorthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalNetWorthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalNetWorthHash();

  @$internal
  @override
  TotalNetWorth create() => TotalNetWorth();
}

String _$totalNetWorthHash() => r'41f4aab46c28414abe9d7c7547e3b88dce5b7a46';

/// Defines the riverpod for the net worth state

abstract class _$TotalNetWorth extends $AsyncNotifier<TotalNetWorthDTO?> {
  FutureOr<TotalNetWorthDTO?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<TotalNetWorthDTO?>, TotalNetWorthDTO?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TotalNetWorthDTO?>, TotalNetWorthDTO?>,
              AsyncValue<TotalNetWorthDTO?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Defines the historical account data

@ProviderFor(HistoricalAccountData)
const historicalAccountDataProvider = HistoricalAccountDataProvider._();

/// Defines the historical account data
final class HistoricalAccountDataProvider
    extends
        $AsyncNotifierProvider<HistoricalAccountData, List<EntityHistory>?> {
  /// Defines the historical account data
  const HistoricalAccountDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historicalAccountDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historicalAccountDataHash();

  @$internal
  @override
  HistoricalAccountData create() => HistoricalAccountData();
}

String _$historicalAccountDataHash() =>
    r'2719f7fffdfe8d1f84b0fd86cade8af4b36c4c2a';

/// Defines the historical account data

abstract class _$HistoricalAccountData
    extends $AsyncNotifier<List<EntityHistory>?> {
  FutureOr<List<EntityHistory>?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<EntityHistory>?>, List<EntityHistory>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<EntityHistory>?>,
                List<EntityHistory>?
              >,
              AsyncValue<List<EntityHistory>?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Defines the overall account timeline

@ProviderFor(AccountTimeline)
const accountTimelineProvider = AccountTimelineFamily._();

/// Defines the overall account timeline
final class AccountTimelineProvider
    extends
        $AsyncNotifierProvider<AccountTimeline, List<HistoricalDataPoint>?> {
  /// Defines the overall account timeline
  const AccountTimelineProvider._({
    required AccountTimelineFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountTimelineProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountTimelineHash();

  @override
  String toString() {
    return r'accountTimelineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountTimeline create() => AccountTimeline();

  @override
  bool operator ==(Object other) {
    return other is AccountTimelineProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTimelineHash() => r'23ecb35de97cb151f2f8f85c1f73a9226b27b141';

/// Defines the overall account timeline

final class AccountTimelineFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountTimeline,
          AsyncValue<List<HistoricalDataPoint>?>,
          List<HistoricalDataPoint>?,
          FutureOr<List<HistoricalDataPoint>?>,
          String
        > {
  const AccountTimelineFamily._()
    : super(
        retry: null,
        name: r'accountTimelineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Defines the overall account timeline

  AccountTimelineProvider call(String accountId) =>
      AccountTimelineProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountTimelineProvider';
}

/// Defines the overall account timeline

abstract class _$AccountTimeline
    extends $AsyncNotifier<List<HistoricalDataPoint>?> {
  late final _$args = ref.$arg as String;
  String get accountId => _$args;

  FutureOr<List<HistoricalDataPoint>?> build(String accountId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<HistoricalDataPoint>?>,
              List<HistoricalDataPoint>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<HistoricalDataPoint>?>,
                List<HistoricalDataPoint>?
              >,
              AsyncValue<List<HistoricalDataPoint>?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
