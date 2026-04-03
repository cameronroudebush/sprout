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

String _$accountsHash() => r'16f2a8ad6aba50d537c9691102dc9fbdcadfd556';

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

/// Riverpod to provide zillow info based on an account ID

@ProviderFor(zillowInfo)
final zillowInfoProvider = ZillowInfoFamily._();

/// Riverpod to provide zillow info based on an account ID

final class ZillowInfoProvider extends $FunctionalProvider<
        AsyncValue<ZillowAsset?>, ZillowAsset?, FutureOr<ZillowAsset?>>
    with $FutureModifier<ZillowAsset?>, $FutureProvider<ZillowAsset?> {
  /// Riverpod to provide zillow info based on an account ID
  ZillowInfoProvider._(
      {required ZillowInfoFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'zillowInfoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$zillowInfoHash();

  @override
  String toString() {
    return r'zillowInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ZillowAsset?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ZillowAsset?> create(Ref ref) {
    final argument = this.argument as String;
    return zillowInfo(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ZillowInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$zillowInfoHash() => r'8f25b60932667024a617d1aa7a5a0824eab8ff68';

/// Riverpod to provide zillow info based on an account ID

final class ZillowInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ZillowAsset?>, String> {
  ZillowInfoFamily._()
      : super(
          retry: null,
          name: r'zillowInfoProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Riverpod to provide zillow info based on an account ID

  ZillowInfoProvider call(
    String accountId,
  ) =>
      ZillowInfoProvider._(argument: accountId, from: this);

  @override
  String toString() => r'zillowInfoProvider';
}
