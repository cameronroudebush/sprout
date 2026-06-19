// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_flow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Authenticated API to cash flow

@ProviderFor(cashFlowApi)
final cashFlowApiProvider = CashFlowApiProvider._();

/// Authenticated API to cash flow

final class CashFlowApiProvider extends $FunctionalProvider<
        AsyncValue<CashFlowApi>, CashFlowApi, FutureOr<CashFlowApi>>
    with $FutureModifier<CashFlowApi>, $FutureProvider<CashFlowApi> {
  /// Authenticated API to cash flow
  CashFlowApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cashFlowApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cashFlowApiHash();

  @$internal
  @override
  $FutureProviderElement<CashFlowApi> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CashFlowApi> create(Ref ref) {
    return cashFlowApi(ref);
  }
}

String _$cashFlowApiHash() => r'ad82c72ab27872d97b68ba4a3a5930d8b2507de6';

/// Sankey data based on time

@ProviderFor(sankeyData)
final sankeyDataProvider = SankeyDataFamily._();

/// Sankey data based on time

final class SankeyDataProvider extends $FunctionalProvider<
        AsyncValue<SankeyData>, SankeyData, FutureOr<SankeyData>>
    with $FutureModifier<SankeyData>, $FutureProvider<SankeyData> {
  /// Sankey data based on time
  SankeyDataProvider._(
      {required SankeyDataFamily super.from,
      required ({
        int year,
        int? month,
        int? day,
        String? accountId,
      })
          super.argument})
      : super(
          retry: null,
          name: r'sankeyDataProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sankeyDataHash();

  @override
  String toString() {
    return r'sankeyDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SankeyData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SankeyData> create(Ref ref) {
    final argument = this.argument as ({
      int year,
      int? month,
      int? day,
      String? accountId,
    });
    return sankeyData(
      ref,
      year: argument.year,
      month: argument.month,
      day: argument.day,
      accountId: argument.accountId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sankeyDataHash() => r'596f7ab3b4ba9d5f6c914062971606492bd9127b';

/// Sankey data based on time

final class SankeyDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<SankeyData>,
            ({
              int year,
              int? month,
              int? day,
              String? accountId,
            })> {
  SankeyDataFamily._()
      : super(
          retry: null,
          name: r'sankeyDataProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Sankey data based on time

  SankeyDataProvider call({
    required int year,
    int? month,
    int? day,
    String? accountId,
  }) =>
      SankeyDataProvider._(argument: (
        year: year,
        month: month,
        day: day,
        accountId: accountId,
      ), from: this);

  @override
  String toString() => r'sankeyDataProvider';
}

/// State for cash flow stats

@ProviderFor(cashFlowStats)
final cashFlowStatsProvider = CashFlowStatsFamily._();

/// State for cash flow stats

final class CashFlowStatsProvider extends $FunctionalProvider<
        AsyncValue<CashFlowStats?>, CashFlowStats?, FutureOr<CashFlowStats?>>
    with $FutureModifier<CashFlowStats?>, $FutureProvider<CashFlowStats?> {
  /// State for cash flow stats
  CashFlowStatsProvider._(
      {required CashFlowStatsFamily super.from,
      required ({
        int year,
        int? month,
        int? day,
        String? accountId,
      })
          super.argument})
      : super(
          retry: null,
          name: r'cashFlowStatsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cashFlowStatsHash();

  @override
  String toString() {
    return r'cashFlowStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CashFlowStats?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CashFlowStats?> create(Ref ref) {
    final argument = this.argument as ({
      int year,
      int? month,
      int? day,
      String? accountId,
    });
    return cashFlowStats(
      ref,
      year: argument.year,
      month: argument.month,
      day: argument.day,
      accountId: argument.accountId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CashFlowStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashFlowStatsHash() => r'00b04a53b081fa4e9e193e7105a53559a659f01b';

/// State for cash flow stats

final class CashFlowStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<CashFlowStats?>,
            ({
              int year,
              int? month,
              int? day,
              String? accountId,
            })> {
  CashFlowStatsFamily._()
      : super(
          retry: null,
          name: r'cashFlowStatsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// State for cash flow stats

  CashFlowStatsProvider call({
    required int year,
    int? month,
    int? day,
    String? accountId,
  }) =>
      CashFlowStatsProvider._(argument: (
        year: year,
        month: month,
        day: day,
        accountId: accountId,
      ), from: this);

  @override
  String toString() => r'cashFlowStatsProvider';
}

/// State for cash flow trends

@ProviderFor(cashFlowTrend)
final cashFlowTrendProvider = CashFlowTrendFamily._();

/// State for cash flow trends

final class CashFlowTrendProvider extends $FunctionalProvider<
        AsyncValue<List<CashFlowTrendStats>?>,
        List<CashFlowTrendStats>?,
        FutureOr<List<CashFlowTrendStats>?>>
    with
        $FutureModifier<List<CashFlowTrendStats>?>,
        $FutureProvider<List<CashFlowTrendStats>?> {
  /// State for cash flow trends
  CashFlowTrendProvider._(
      {required CashFlowTrendFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'cashFlowTrendProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cashFlowTrendHash();

  @override
  String toString() {
    return r'cashFlowTrendProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CashFlowTrendStats>?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashFlowTrendStats>?> create(Ref ref) {
    final argument = this.argument as int;
    return cashFlowTrend(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CashFlowTrendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashFlowTrendHash() => r'4bcda03740348c8424aa1cc7fe1559b9f7f6180a';

/// State for cash flow trends

final class CashFlowTrendFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CashFlowTrendStats>?>, int> {
  CashFlowTrendFamily._()
      : super(
          retry: null,
          name: r'cashFlowTrendProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// State for cash flow trends

  CashFlowTrendProvider call(
    int months,
  ) =>
      CashFlowTrendProvider._(argument: months, from: this);

  @override
  String toString() => r'cashFlowTrendProvider';
}

/// Monthly spending state

@ProviderFor(MonthlySpending)
final monthlySpendingProvider = MonthlySpendingFamily._();

/// Monthly spending state
final class MonthlySpendingProvider
    extends $AsyncNotifierProvider<MonthlySpending, CashFlowSpending?> {
  /// Monthly spending state
  MonthlySpendingProvider._(
      {required MonthlySpendingFamily super.from,
      required ({
        int months,
        int? categories,
      })
          super.argument})
      : super(
          retry: null,
          name: r'monthlySpendingProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$monthlySpendingHash();

  @override
  String toString() {
    return r'monthlySpendingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MonthlySpending create() => MonthlySpending();

  @override
  bool operator ==(Object other) {
    return other is MonthlySpendingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlySpendingHash() => r'7c07c34194ef33ce7c896a702a8a9b929922605a';

/// Monthly spending state

final class MonthlySpendingFamily extends $Family
    with
        $ClassFamilyOverride<
            MonthlySpending,
            AsyncValue<CashFlowSpending?>,
            CashFlowSpending?,
            FutureOr<CashFlowSpending?>,
            ({
              int months,
              int? categories,
            })> {
  MonthlySpendingFamily._()
      : super(
          retry: null,
          name: r'monthlySpendingProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Monthly spending state

  MonthlySpendingProvider call({
    int months = 4,
    int? categories,
  }) =>
      MonthlySpendingProvider._(argument: (
        months: months,
        categories: categories,
      ), from: this);

  @override
  String toString() => r'monthlySpendingProvider';
}

/// Monthly spending state

abstract class _$MonthlySpending extends $AsyncNotifier<CashFlowSpending?> {
  late final _$args = ref.$arg as ({
    int months,
    int? categories,
  });
  int get months => _$args.months;
  int? get categories => _$args.categories;

  FutureOr<CashFlowSpending?> build({
    int months = 4,
    int? categories,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CashFlowSpending?>, CashFlowSpending?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CashFlowSpending?>, CashFlowSpending?>,
        AsyncValue<CashFlowSpending?>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              months: _$args.months,
              categories: _$args.categories,
            ));
  }
}

@ProviderFor(CashFlowComparisonTimeline)
final cashFlowComparisonTimelineProvider = CashFlowComparisonTimelineFamily._();

final class CashFlowComparisonTimelineProvider extends $AsyncNotifierProvider<
    CashFlowComparisonTimeline, CashFlowComparisonDTO?> {
  CashFlowComparisonTimelineProvider._(
      {required CashFlowComparisonTimelineFamily super.from,
      required ({
        int baselineYear,
        int? baselineMonth,
        int targetYear,
        int? targetMonth,
      })
          super.argument})
      : super(
          retry: null,
          name: r'cashFlowComparisonTimelineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cashFlowComparisonTimelineHash();

  @override
  String toString() {
    return r'cashFlowComparisonTimelineProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CashFlowComparisonTimeline create() => CashFlowComparisonTimeline();

  @override
  bool operator ==(Object other) {
    return other is CashFlowComparisonTimelineProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashFlowComparisonTimelineHash() =>
    r'942f0a03a195b068e6dbfd4519f485e1e7d6f77f';

final class CashFlowComparisonTimelineFamily extends $Family
    with
        $ClassFamilyOverride<
            CashFlowComparisonTimeline,
            AsyncValue<CashFlowComparisonDTO?>,
            CashFlowComparisonDTO?,
            FutureOr<CashFlowComparisonDTO?>,
            ({
              int baselineYear,
              int? baselineMonth,
              int targetYear,
              int? targetMonth,
            })> {
  CashFlowComparisonTimelineFamily._()
      : super(
          retry: null,
          name: r'cashFlowComparisonTimelineProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  CashFlowComparisonTimelineProvider call({
    required int baselineYear,
    int? baselineMonth,
    required int targetYear,
    int? targetMonth,
  }) =>
      CashFlowComparisonTimelineProvider._(argument: (
        baselineYear: baselineYear,
        baselineMonth: baselineMonth,
        targetYear: targetYear,
        targetMonth: targetMonth,
      ), from: this);

  @override
  String toString() => r'cashFlowComparisonTimelineProvider';
}

abstract class _$CashFlowComparisonTimeline
    extends $AsyncNotifier<CashFlowComparisonDTO?> {
  late final _$args = ref.$arg as ({
    int baselineYear,
    int? baselineMonth,
    int targetYear,
    int? targetMonth,
  });
  int get baselineYear => _$args.baselineYear;
  int? get baselineMonth => _$args.baselineMonth;
  int get targetYear => _$args.targetYear;
  int? get targetMonth => _$args.targetMonth;

  FutureOr<CashFlowComparisonDTO?> build({
    required int baselineYear,
    int? baselineMonth,
    required int targetYear,
    int? targetMonth,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<CashFlowComparisonDTO?>, CashFlowComparisonDTO?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CashFlowComparisonDTO?>, CashFlowComparisonDTO?>,
        AsyncValue<CashFlowComparisonDTO?>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              baselineYear: _$args.baselineYear,
              baselineMonth: _$args.baselineMonth,
              targetYear: _$args.targetYear,
              targetMonth: _$args.targetMonth,
            ));
  }
}

/// Live dynamic provider tracking discrete daily spending aggregates over a given month canvas

@ProviderFor(dailySpending)
final dailySpendingProvider = DailySpendingFamily._();

/// Live dynamic provider tracking discrete daily spending aggregates over a given month canvas

final class DailySpendingProvider extends $FunctionalProvider<
        AsyncValue<Map<int, double>>,
        Map<int, double>,
        FutureOr<Map<int, double>>>
    with $FutureModifier<Map<int, double>>, $FutureProvider<Map<int, double>> {
  /// Live dynamic provider tracking discrete daily spending aggregates over a given month canvas
  DailySpendingProvider._(
      {required DailySpendingFamily super.from,
      required ({
        int month,
        int year,
      })
          super.argument})
      : super(
          retry: null,
          name: r'dailySpendingProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailySpendingHash();

  @override
  String toString() {
    return r'dailySpendingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<int, double>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, double>> create(Ref ref) {
    final argument = this.argument as ({
      int month,
      int year,
    });
    return dailySpending(
      ref,
      month: argument.month,
      year: argument.year,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DailySpendingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailySpendingHash() => r'2b7fc0a3ae4504359e2083e817ac79d347565fbc';

/// Live dynamic provider tracking discrete daily spending aggregates over a given month canvas

final class DailySpendingFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<Map<int, double>>,
            ({
              int month,
              int year,
            })> {
  DailySpendingFamily._()
      : super(
          retry: null,
          name: r'dailySpendingProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Live dynamic provider tracking discrete daily spending aggregates over a given month canvas

  DailySpendingProvider call({
    required int month,
    required int year,
  }) =>
      DailySpendingProvider._(argument: (
        month: month,
        year: year,
      ), from: this);

  @override
  String toString() => r'dailySpendingProvider';
}
