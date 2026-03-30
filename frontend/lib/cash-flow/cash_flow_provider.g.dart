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

String _$sankeyDataHash() => r'663aee4dc0e8937bf533f78333406418bfe8816e';

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

String _$cashFlowStatsHash() => r'918718ba8c35e7be9569a9b1b87807b53eff15fa';

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
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CashFlowSpending?>, CashFlowSpending?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CashFlowSpending?>, CashFlowSpending?>,
        AsyncValue<CashFlowSpending?>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              months: _$args.months,
              categories: _$args.categories,
            ));
  }
}
