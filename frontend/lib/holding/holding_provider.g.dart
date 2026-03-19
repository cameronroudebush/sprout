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

/// Provides state to the account holding history per account id

@ProviderFor(AccountHoldingsHistory)
final accountHoldingsHistoryProvider = AccountHoldingsHistoryFamily._();

/// Provides state to the account holding history per account id
final class AccountHoldingsHistoryProvider extends $AsyncNotifierProvider<
    AccountHoldingsHistory, List<EntityHistory>> {
  /// Provides state to the account holding history per account id
  AccountHoldingsHistoryProvider._(
      {required AccountHoldingsHistoryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'accountHoldingsHistoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountHoldingsHistoryHash();

  @override
  String toString() {
    return r'accountHoldingsHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountHoldingsHistory create() => AccountHoldingsHistory();

  @override
  bool operator ==(Object other) {
    return other is AccountHoldingsHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountHoldingsHistoryHash() =>
    r'7fd340017cf003d047ba3d5041bdfbdedc3b9ecf';

/// Provides state to the account holding history per account id

final class AccountHoldingsHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
            AccountHoldingsHistory,
            AsyncValue<List<EntityHistory>>,
            List<EntityHistory>,
            FutureOr<List<EntityHistory>>,
            String> {
  AccountHoldingsHistoryFamily._()
      : super(
          retry: null,
          name: r'accountHoldingsHistoryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provides state to the account holding history per account id

  AccountHoldingsHistoryProvider call(
    String accountId,
  ) =>
      AccountHoldingsHistoryProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountHoldingsHistoryProvider';
}

/// Provides state to the account holding history per account id

abstract class _$AccountHoldingsHistory
    extends $AsyncNotifier<List<EntityHistory>> {
  late final _$args = ref.$arg as String;
  String get accountId => _$args;

  FutureOr<List<EntityHistory>> build(
    String accountId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<EntityHistory>>, List<EntityHistory>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<EntityHistory>>, List<EntityHistory>>,
        AsyncValue<List<EntityHistory>>,
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

/// Riverpod that provides live price of a stock utilizing the backend API

@ProviderFor(LivePrice)
final livePriceProvider = LivePriceFamily._();

/// Riverpod that provides live price of a stock utilizing the backend API
final class LivePriceProvider
    extends $AsyncNotifierProvider<LivePrice, MarketIndexDto?> {
  /// Riverpod that provides live price of a stock utilizing the backend API
  LivePriceProvider._(
      {required LivePriceFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'livePriceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$livePriceHash();

  @override
  String toString() {
    return r'livePriceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LivePrice create() => LivePrice();

  @override
  bool operator ==(Object other) {
    return other is LivePriceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$livePriceHash() => r'96715e8ffc836594a4ac53c12671b1f1aa4d079c';

/// Riverpod that provides live price of a stock utilizing the backend API

final class LivePriceFamily extends $Family
    with
        $ClassFamilyOverride<LivePrice, AsyncValue<MarketIndexDto?>,
            MarketIndexDto?, FutureOr<MarketIndexDto?>, String> {
  LivePriceFamily._()
      : super(
          retry: null,
          name: r'livePriceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Riverpod that provides live price of a stock utilizing the backend API

  LivePriceProvider call(
    String symbol,
  ) =>
      LivePriceProvider._(argument: symbol, from: this);

  @override
  String toString() => r'livePriceProvider';
}

/// Riverpod that provides live price of a stock utilizing the backend API

abstract class _$LivePrice extends $AsyncNotifier<MarketIndexDto?> {
  late final _$args = ref.$arg as String;
  String get symbol => _$args;

  FutureOr<MarketIndexDto?> build(
    String symbol,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MarketIndexDto?>, MarketIndexDto?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<MarketIndexDto?>, MarketIndexDto?>,
        AsyncValue<MarketIndexDto?>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
