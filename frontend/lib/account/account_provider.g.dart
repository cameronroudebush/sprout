// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the authenticated API for the client

@ProviderFor(accountApi)
final accountApiProvider = AccountApiProvider._();

/// Returns the authenticated API for the client

final class AccountApiProvider extends $FunctionalProvider<
        AsyncValue<AccountApi>, AccountApi, FutureOr<AccountApi>>
    with $FutureModifier<AccountApi>, $FutureProvider<AccountApi> {
  /// Returns the authenticated API for the client
  AccountApiProvider._()
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

@ProviderFor(Accounts)
final accountsProvider = AccountsProvider._();

final class AccountsProvider
    extends $AsyncNotifierProvider<Accounts, AccountState> {
  AccountsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountsHash();

  @$internal
  @override
  Accounts create() => Accounts();
}

String _$accountsHash() => r'bd5b1282ce1c8cce574ed04bc303554e547c62b0';

abstract class _$Accounts extends $AsyncNotifier<AccountState> {
  FutureOr<AccountState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AccountState>, AccountState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AccountState>, AccountState>,
        AsyncValue<AccountState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
