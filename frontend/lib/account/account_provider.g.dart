// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the authenticated API for the client

@ProviderFor(accountApi)
const accountApiProvider = AccountApiProvider._();

/// Returns the authenticated API for the client

final class AccountApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountApi>,
          AccountApi,
          FutureOr<AccountApi>
        >
    with $FutureModifier<AccountApi>, $FutureProvider<AccountApi> {
  /// Returns the authenticated API for the client
  const AccountApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountApiHash();

  @$internal
  @override
  $FutureProviderElement<AccountApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AccountApi> create(Ref ref) {
    return accountApi(ref);
  }
}

String _$accountApiHash() => r'17c51225bb51701c62c0754e92c6b0c2f4a652ee';

@ProviderFor(AccountList)
const accountListProvider = AccountListProvider._();

final class AccountListProvider
    extends $AsyncNotifierProvider<AccountList, AccountState> {
  const AccountListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountListHash();

  @$internal
  @override
  AccountList create() => AccountList();
}

String _$accountListHash() => r'8c0931825d645b2159a8663ea4af426ed29f1210';

abstract class _$AccountList extends $AsyncNotifier<AccountState> {
  FutureOr<AccountState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AccountState>, AccountState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountState>, AccountState>,
              AsyncValue<AccountState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
