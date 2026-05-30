// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the API for the holding info

@ProviderFor(holdingApi)
final holdingApiProvider = HoldingApiProvider._();

/// Provides the API for the holding info

final class HoldingApiProvider extends $FunctionalProvider<
        AsyncValue<HoldingApi>, HoldingApi, FutureOr<HoldingApi>>
    with $FutureModifier<HoldingApi>, $FutureProvider<HoldingApi> {
  /// Provides the API for the holding info
  HoldingApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'holdingApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$holdingApiHash();

  @$internal
  @override
  $FutureProviderElement<HoldingApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HoldingApi> create(Ref ref) {
    return holdingApi(ref);
  }
}

String _$holdingApiHash() => r'4cffc7e0ac0197fb443f478bb35f2fcd0da28910';

/// Provides state to the account holdings info

@ProviderFor(AccountHoldings)
final accountHoldingsProvider = AccountHoldingsFamily._();

/// Provides state to the account holdings info
final class AccountHoldingsProvider
    extends $AsyncNotifierProvider<AccountHoldings, List<Holding>> {
  /// Provides state to the account holdings info
  AccountHoldingsProvider._(
      {required AccountHoldingsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'accountHoldingsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountHoldingsHash();

  @override
  String toString() {
    return r'accountHoldingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountHoldings create() => AccountHoldings();

  @override
  bool operator ==(Object other) {
    return other is AccountHoldingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountHoldingsHash() => r'1d4a77dd177db03c78e457886fd8eb550c7e05e9';

/// Provides state to the account holdings info

final class AccountHoldingsFamily extends $Family
    with
        $ClassFamilyOverride<AccountHoldings, AsyncValue<List<Holding>>,
            List<Holding>, FutureOr<List<Holding>>, String> {
  AccountHoldingsFamily._()
      : super(
          retry: null,
          name: r'accountHoldingsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides state to the account holdings info

  AccountHoldingsProvider call(
    String accountId,
  ) =>
      AccountHoldingsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountHoldingsProvider';
}

/// Provides state to the account holdings info

abstract class _$AccountHoldings extends $AsyncNotifier<List<Holding>> {
  late final _$args = ref.$arg as String;
  String get accountId => _$args;

  FutureOr<List<Holding>> build(
    String accountId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Holding>>, List<Holding>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Holding>>, List<Holding>>,
        AsyncValue<List<Holding>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Provides state to the holding history per holding id

@ProviderFor(AccountHoldingHistory)
final accountHoldingHistoryProvider = AccountHoldingHistoryFamily._();

/// Provides state to the holding history per holding id
final class AccountHoldingHistoryProvider
    extends $AsyncNotifierProvider<AccountHoldingHistory, EntityHistory?> {
  /// Provides state to the holding history per holding id
  AccountHoldingHistoryProvider._(
      {required AccountHoldingHistoryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'accountHoldingHistoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountHoldingHistoryHash();

  @override
  String toString() {
    return r'accountHoldingHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountHoldingHistory create() => AccountHoldingHistory();

  @override
  bool operator ==(Object other) {
    return other is AccountHoldingHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountHoldingHistoryHash() =>
    r'3a6acfa792c9fcc70f85f965b8f75b494bcaa5e3';

/// Provides state to the holding history per holding id

final class AccountHoldingHistoryFamily extends $Family
    with
        $ClassFamilyOverride<AccountHoldingHistory, AsyncValue<EntityHistory?>,
            EntityHistory?, FutureOr<EntityHistory?>, String> {
  AccountHoldingHistoryFamily._()
      : super(
          retry: null,
          name: r'accountHoldingHistoryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides state to the holding history per holding id

  AccountHoldingHistoryProvider call(
    String holdingId,
  ) =>
      AccountHoldingHistoryProvider._(argument: holdingId, from: this);

  @override
  String toString() => r'accountHoldingHistoryProvider';
}

/// Provides state to the holding history per holding id

abstract class _$AccountHoldingHistory extends $AsyncNotifier<EntityHistory?> {
  late final _$args = ref.$arg as String;
  String get holdingId => _$args;

  FutureOr<EntityHistory?> build(
    String holdingId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EntityHistory?>, EntityHistory?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<EntityHistory?>, EntityHistory?>,
        AsyncValue<EntityHistory?>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Provides state to the account holding timelines

@ProviderFor(HoldingTimeline)
final holdingTimelineProvider = HoldingTimelineFamily._();

/// Provides state to the account holding timelines
final class HoldingTimelineProvider
    extends $AsyncNotifierProvider<HoldingTimeline, List<HistoricalDataPoint>> {
  /// Provides state to the account holding timelines
  HoldingTimelineProvider._(
      {required HoldingTimelineFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'holdingTimelineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$holdingTimelineHash();

  @override
  String toString() {
    return r'holdingTimelineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HoldingTimeline create() => HoldingTimeline();

  @override
  bool operator ==(Object other) {
    return other is HoldingTimelineProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$holdingTimelineHash() => r'7bffb548699a1a7d44f3a23d349957a46e3f7962';

/// Provides state to the account holding timelines

final class HoldingTimelineFamily extends $Family
    with
        $ClassFamilyOverride<
            HoldingTimeline,
            AsyncValue<List<HistoricalDataPoint>>,
            List<HistoricalDataPoint>,
            FutureOr<List<HistoricalDataPoint>>,
            String> {
  HoldingTimelineFamily._()
      : super(
          retry: null,
          name: r'holdingTimelineProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides state to the account holding timelines

  HoldingTimelineProvider call(
    String holdingId,
  ) =>
      HoldingTimelineProvider._(argument: holdingId, from: this);

  @override
  String toString() => r'holdingTimelineProvider';
}

/// Provides state to the account holding timelines

abstract class _$HoldingTimeline
    extends $AsyncNotifier<List<HistoricalDataPoint>> {
  late final _$args = ref.$arg as String;
  String get holdingId => _$args;

  FutureOr<List<HistoricalDataPoint>> build(
    String holdingId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<HistoricalDataPoint>>,
        List<HistoricalDataPoint>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<HistoricalDataPoint>>,
            List<HistoricalDataPoint>>,
        AsyncValue<List<HistoricalDataPoint>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Provides information for the major indices for holding content

@ProviderFor(MajorIndices)
final majorIndicesProvider = MajorIndicesProvider._();

/// Provides information for the major indices for holding content
final class MajorIndicesProvider
    extends $AsyncNotifierProvider<MajorIndices, List<MarketIndexDto>> {
  /// Provides information for the major indices for holding content
  MajorIndicesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'majorIndicesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$majorIndicesHash();

  @$internal
  @override
  MajorIndices create() => MajorIndices();
}

String _$majorIndicesHash() => r'6080e07669598bb49b3a4afe842db31cd0db6952';

/// Provides information for the major indices for holding content

abstract class _$MajorIndices extends $AsyncNotifier<List<MarketIndexDto>> {
  FutureOr<List<MarketIndexDto>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<MarketIndexDto>>, List<MarketIndexDto>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MarketIndexDto>>, List<MarketIndexDto>>,
        AsyncValue<List<MarketIndexDto>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// A DataLoader style provider that batches requests from the UI

@ProviderFor(BatchedLivePrices)
final batchedLivePricesProvider = BatchedLivePricesProvider._();

/// A DataLoader style provider that batches requests from the UI
final class BatchedLivePricesProvider
    extends $NotifierProvider<BatchedLivePrices, Map<String, MarketIndexDto>> {
  /// A DataLoader style provider that batches requests from the UI
  BatchedLivePricesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'batchedLivePricesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$batchedLivePricesHash();

  @$internal
  @override
  BatchedLivePrices create() => BatchedLivePrices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, MarketIndexDto> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, MarketIndexDto>>(value),
    );
  }
}

String _$batchedLivePricesHash() => r'cfb474137afc897d4301374b89b3c61392549b1d';

/// A DataLoader style provider that batches requests from the UI

abstract class _$BatchedLivePrices
    extends $Notifier<Map<String, MarketIndexDto>> {
  Map<String, MarketIndexDto> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<Map<String, MarketIndexDto>, Map<String, MarketIndexDto>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, MarketIndexDto>, Map<String, MarketIndexDto>>,
        Map<String, MarketIndexDto>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provides the 7-day historical performance timeline for major market indicies.
/// Updates automatically on a rolling 1-hour interval matching the backend's cache policy.

@ProviderFor(MajorIndicesTimeline)
final majorIndicesTimelineProvider = MajorIndicesTimelineProvider._();

/// Provides the 7-day historical performance timeline for major market indicies.
/// Updates automatically on a rolling 1-hour interval matching the backend's cache policy.
final class MajorIndicesTimelineProvider extends $AsyncNotifierProvider<
    MajorIndicesTimeline, List<MajorIndexTimelineDto>> {
  /// Provides the 7-day historical performance timeline for major market indicies.
  /// Updates automatically on a rolling 1-hour interval matching the backend's cache policy.
  MajorIndicesTimelineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'majorIndicesTimelineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$majorIndicesTimelineHash();

  @$internal
  @override
  MajorIndicesTimeline create() => MajorIndicesTimeline();
}

String _$majorIndicesTimelineHash() =>
    r'dcf0818b25f00ff8e78b1766b917d9750f5d94ef';

/// Provides the 7-day historical performance timeline for major market indicies.
/// Updates automatically on a rolling 1-hour interval matching the backend's cache policy.

abstract class _$MajorIndicesTimeline
    extends $AsyncNotifier<List<MajorIndexTimelineDto>> {
  FutureOr<List<MajorIndexTimelineDto>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<MajorIndexTimelineDto>>,
        List<MajorIndexTimelineDto>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MajorIndexTimelineDto>>,
            List<MajorIndexTimelineDto>>,
        AsyncValue<List<MajorIndexTimelineDto>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
