// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_rule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State for the authenticated API

@ProviderFor(transactionRuleApi)
const transactionRuleApiProvider = TransactionRuleApiProvider._();

/// State for the authenticated API

final class TransactionRuleApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<TransactionRuleApi>,
          TransactionRuleApi,
          FutureOr<TransactionRuleApi>
        >
    with
        $FutureModifier<TransactionRuleApi>,
        $FutureProvider<TransactionRuleApi> {
  /// State for the authenticated API
  const TransactionRuleApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRuleApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRuleApiHash();

  @$internal
  @override
  $FutureProviderElement<TransactionRuleApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TransactionRuleApi> create(Ref ref) {
    return transactionRuleApi(ref);
  }
}

String _$transactionRuleApiHash() =>
    r'8214c4bf1c3f369300c6af49fe0b85044c8a51b9';

@ProviderFor(TransactionRules)
const transactionRulesProvider = TransactionRulesProvider._();

final class TransactionRulesProvider
    extends $AsyncNotifierProvider<TransactionRules, TransactionRuleState> {
  const TransactionRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRulesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRulesHash();

  @$internal
  @override
  TransactionRules create() => TransactionRules();
}

String _$transactionRulesHash() => r'baab756133d61181aa6bf3081b6133e27fc3102c';

abstract class _$TransactionRules extends $AsyncNotifier<TransactionRuleState> {
  FutureOr<TransactionRuleState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<TransactionRuleState>, TransactionRuleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TransactionRuleState>,
                TransactionRuleState
              >,
              AsyncValue<TransactionRuleState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
