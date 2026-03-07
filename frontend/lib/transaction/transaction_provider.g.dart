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

@ProviderFor(TransactionList)
const transactionListProvider = TransactionListProvider._();

final class TransactionListProvider
    extends $AsyncNotifierProvider<TransactionList, TransactionState> {
  const TransactionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionListHash();

  @$internal
  @override
  TransactionList create() => TransactionList();
}

String _$transactionListHash() => r'69543fca46a759907e05e1ad1eb736ed076c4223';

abstract class _$TransactionList extends $AsyncNotifier<TransactionState> {
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
