// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the transaction api

@ProviderFor(transactionApi)
const transactionApiProvider = TransactionApiProvider._();

/// Provider for the transaction api

final class TransactionApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<TransactionApi>,
          TransactionApi,
          FutureOr<TransactionApi>
        >
    with $FutureModifier<TransactionApi>, $FutureProvider<TransactionApi> {
  /// Provider for the transaction api
  const TransactionApiProvider._()
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
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TransactionApi> create(Ref ref) {
    return transactionApi(ref);
  }
}

String _$transactionApiHash() => r'd7537afeaaf1c267fadfc572064951e09529b86c';

@ProviderFor(Transactions)
const transactionsProvider = TransactionsProvider._();

final class TransactionsProvider
    extends $AsyncNotifierProvider<Transactions, TransactionState> {
  const TransactionsProvider._()
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

String _$transactionsHash() => r'ffef2954457abaecb09fcc0093a2a7529a1cd4c3';

abstract class _$Transactions extends $AsyncNotifier<TransactionState> {
  FutureOr<TransactionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<TransactionState>, TransactionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransactionState>, TransactionState>,
              AsyncValue<TransactionState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// List of filtered transactions based on our state

@ProviderFor(filteredTransactions)
const filteredTransactionsProvider = FilteredTransactionsFamily._();

/// List of filtered transactions based on our state

final class FilteredTransactionsProvider
    extends
        $FunctionalProvider<
          List<Transaction>,
          List<Transaction>,
          List<Transaction>
        >
    with $Provider<List<Transaction>> {
  /// List of filtered transactions based on our state
  const FilteredTransactionsProvider._({
    required FilteredTransactionsFamily super.from,
    required ({String? accountId, String? categoryId, String? search})
    super.argument,
  }) : super(
         retry: null,
         name: r'filteredTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredTransactionsHash();

  @override
  String toString() {
    return r'filteredTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    final argument =
        this.argument
            as ({String? accountId, String? categoryId, String? search});
    return filteredTransactions(
      ref,
      accountId: argument.accountId,
      categoryId: argument.categoryId,
      search: argument.search,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredTransactionsHash() =>
    r'75cf6fa95c68ad00f0313f59a52f9aca455224c8';

/// List of filtered transactions based on our state

final class FilteredTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<Transaction>,
          ({String? accountId, String? categoryId, String? search})
        > {
  const FilteredTransactionsFamily._()
    : super(
        retry: null,
        name: r'filteredTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// List of filtered transactions based on our state

  FilteredTransactionsProvider call({
    String? accountId,
    String? categoryId,
    String? search,
  }) => FilteredTransactionsProvider._(
    argument: (accountId: accountId, categoryId: categoryId, search: search),
    from: this,
  );

  @override
  String toString() => r'filteredTransactionsProvider';
}

/// Provider to track transaction subscriptions

@ProviderFor(TransactionSubscriptions)
const transactionSubscriptionsProvider = TransactionSubscriptionsProvider._();

/// Provider to track transaction subscriptions
final class TransactionSubscriptionsProvider
    extends
        $AsyncNotifierProvider<
          TransactionSubscriptions,
          List<TransactionSubscription>
        > {
  /// Provider to track transaction subscriptions
  const TransactionSubscriptionsProvider._()
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
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<TransactionSubscription>>,
              List<TransactionSubscription>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TransactionSubscription>>,
                List<TransactionSubscription>
              >,
              AsyncValue<List<TransactionSubscription>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
