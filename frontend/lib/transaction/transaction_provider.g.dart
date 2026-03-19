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

String _$transactionsHash() => r'f61a960b9ab90f8e5f6fafeb016499d782bebb01';

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
    r'4788f7e8119aa8bbd4c558aae10bedd7dbeac240';

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
