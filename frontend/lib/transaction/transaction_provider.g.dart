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
final transactionsProvider = TransactionsFamily._();

final class TransactionsProvider
    extends $AsyncNotifierProvider<Transactions, TransactionState> {
  TransactionsProvider._(
      {required TransactionsFamily super.from,
      required TransactionFilter super.argument})
      : super(
          retry: null,
          name: r'transactionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @override
  String toString() {
    return r'transactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Transactions create() => Transactions();

  @override
  bool operator ==(Object other) {
    return other is TransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionsHash() => r'4cb25b9facc8cac506df482966033adbadec985b';

final class TransactionsFamily extends $Family
    with
        $ClassFamilyOverride<Transactions, AsyncValue<TransactionState>,
            TransactionState, FutureOr<TransactionState>, TransactionFilter> {
  TransactionsFamily._()
      : super(
          retry: null,
          name: r'transactionsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  TransactionsProvider call(
    TransactionFilter filter,
  ) =>
      TransactionsProvider._(argument: filter, from: this);

  @override
  String toString() => r'transactionsProvider';
}

abstract class _$Transactions extends $AsyncNotifier<TransactionState> {
  late final _$args = ref.$arg as TransactionFilter;
  TransactionFilter get filter => _$args;

  FutureOr<TransactionState> build(
    TransactionFilter filter,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransactionState>, TransactionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TransactionState>, TransactionState>,
        AsyncValue<TransactionState>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

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
    r'5a2045e5615fc48cbb5c3bbb75124b34af00d990';

/// Provider to track transaction subscriptions

abstract class _$TransactionSubscriptions
    extends $AsyncNotifier<List<TransactionSubscription>> {
  FutureOr<List<TransactionSubscription>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TransactionSubscription>>,
        List<TransactionSubscription>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TransactionSubscription>>,
            List<TransactionSubscription>>,
        AsyncValue<List<TransactionSubscription>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
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

/// Fetches a single transaction by ID, checking existing default provider state first.

@ProviderFor(transactionById)
final transactionByIdProvider = TransactionByIdFamily._();

/// Fetches a single transaction by ID, checking existing default provider state first.

final class TransactionByIdProvider extends $FunctionalProvider<
        AsyncValue<Transaction?>, Transaction?, FutureOr<Transaction?>>
    with $FutureModifier<Transaction?>, $FutureProvider<Transaction?> {
  /// Fetches a single transaction by ID, checking existing default provider state first.
  TransactionByIdProvider._(
      {required TransactionByIdFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'transactionByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionByIdHash();

  @override
  String toString() {
    return r'transactionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Transaction?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Transaction?> create(Ref ref) {
    final argument = this.argument as String;
    return transactionById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionByIdHash() => r'41fb8044a5d78dda922d9fbff6fb205066e76c04';

/// Fetches a single transaction by ID, checking existing default provider state first.

final class TransactionByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Transaction?>, String> {
  TransactionByIdFamily._()
      : super(
          retry: null,
          name: r'transactionByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches a single transaction by ID, checking existing default provider state first.

  TransactionByIdProvider call(
    String id,
  ) =>
      TransactionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'transactionByIdProvider';
}
