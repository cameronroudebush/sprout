// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the transaction api

@ProviderFor(transactionApi)
final transactionApiProvider = TransactionApiProvider._();

/// Provider for the transaction api

final class TransactionApiProvider extends $FunctionalProvider<
        AsyncValue<TransactionApi>, TransactionApi, FutureOr<TransactionApi>>
    with $FutureModifier<TransactionApi>, $FutureProvider<TransactionApi> {
  /// Provider for the transaction api
  TransactionApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionApiHash();

  @$internal
  @override
  $FutureProviderElement<TransactionApi> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TransactionApi> create(Ref ref) {
    return transactionApi(ref);
  }
}

String _$transactionApiHash() => r'd7537afeaaf1c267fadfc572064951e09529b86c';

@ProviderFor(Transactions)
final transactionsProvider = TransactionsProvider._();

final class TransactionsProvider
    extends $AsyncNotifierProvider<Transactions, TransactionState> {
  TransactionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @$internal
  @override
  Transactions create() => Transactions();
}

String _$transactionsHash() => r'cf76b794c348108a4b090930299da699e260f32c';

abstract class _$Transactions extends $AsyncNotifier<TransactionState> {
  FutureOr<TransactionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransactionState>, TransactionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TransactionState>, TransactionState>,
        AsyncValue<TransactionState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TransactionFilterState)
final transactionFilterStateProvider = TransactionFilterStateProvider._();

final class TransactionFilterStateProvider
    extends $NotifierProvider<TransactionFilterState, TransactionFilter> {
  TransactionFilterStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionFilterStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionFilterStateHash();

  @$internal
  @override
  TransactionFilterState create() => TransactionFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFilter>(value),
    );
  }
}

String _$transactionFilterStateHash() =>
    r'7df8ac1a9710089fc2dc3361c0730a16bc213c93';

abstract class _$TransactionFilterState extends $Notifier<TransactionFilter> {
  TransactionFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TransactionFilter, TransactionFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TransactionFilter, TransactionFilter>,
        TransactionFilter,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// List of filtered transactions based on our state

@ProviderFor(filteredTransactions)
final filteredTransactionsProvider = FilteredTransactionsProvider._();

/// List of filtered transactions based on our state

final class FilteredTransactionsProvider extends $FunctionalProvider<
    List<Transaction>,
    List<Transaction>,
    List<Transaction>> with $Provider<List<Transaction>> {
  /// List of filtered transactions based on our state
  FilteredTransactionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredTransactionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    return filteredTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$filteredTransactionsHash() =>
    r'e2469d7faa4451667db1ffea70641526aabaf42d';

/// Provider to track transaction subscriptions

@ProviderFor(TransactionSubscriptions)
final transactionSubscriptionsProvider = TransactionSubscriptionsProvider._();

/// Provider to track transaction subscriptions
final class TransactionSubscriptionsProvider extends $AsyncNotifierProvider<
    TransactionSubscriptions, List<TransactionSubscription>> {
  /// Provider to track transaction subscriptions
  TransactionSubscriptionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionSubscriptionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionSubscriptionsHash();

  @$internal
  @override
  TransactionSubscriptions create() => TransactionSubscriptions();
}

String _$transactionSubscriptionsHash() =>
    r'2424ab003c59bd26cf8a27fd57f21a401f2ffb69';

/// Provider to track transaction subscriptions

abstract class _$TransactionSubscriptions
    extends $AsyncNotifier<List<TransactionSubscription>> {
  FutureOr<List<TransactionSubscription>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TransactionSubscription>>,
        List<TransactionSubscription>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TransactionSubscription>>,
            List<TransactionSubscription>>,
        AsyncValue<List<TransactionSubscription>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// A provider that grabs transactions just for the given day

@ProviderFor(transactionsForDay)
final transactionsForDayProvider = TransactionsForDayFamily._();

/// A provider that grabs transactions just for the given day

final class TransactionsForDayProvider extends $FunctionalProvider<
        AsyncValue<List<Transaction>>,
        List<Transaction>,
        FutureOr<List<Transaction>>>
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  /// A provider that grabs transactions just for the given day
  TransactionsForDayProvider._(
      {required TransactionsForDayFamily super.from,
      required DateTime super.argument})
      : super(
          retry: null,
          name: r'transactionsForDayProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionsForDayHash();

  @override
  String toString() {
    return r'transactionsForDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return transactionsForDay(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsForDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionsForDayHash() =>
    r'08aa786c5ffc6a4519e4a110fbffc72e9b388cf6';

/// A provider that grabs transactions just for the given day

final class TransactionsForDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Transaction>>, DateTime> {
  TransactionsForDayFamily._()
      : super(
          retry: null,
          name: r'transactionsForDayProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// A provider that grabs transactions just for the given day

  TransactionsForDayProvider call(
    DateTime day,
  ) =>
      TransactionsForDayProvider._(argument: day, from: this);

  @override
  String toString() => r'transactionsForDayProvider';
}
