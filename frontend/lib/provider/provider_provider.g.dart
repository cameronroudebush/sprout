// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the authenticated API for the provider client

@ProviderFor(providerApi)
final providerApiProvider = ProviderApiProvider._();

/// Returns the authenticated API for the provider client

final class ProviderApiProvider extends $FunctionalProvider<
        AsyncValue<ProviderApi>, ProviderApi, FutureOr<ProviderApi>>
    with $FutureModifier<ProviderApi>, $FutureProvider<ProviderApi> {
  /// Returns the authenticated API for the provider client
  ProviderApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'providerApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$providerApiHash();

  @$internal
  @override
  $FutureProviderElement<ProviderApi> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ProviderApi> create(Ref ref) {
    return providerApi(ref);
  }
}

String _$providerApiHash() => r'fe1fa23462b9f14acf5b11671a93af08727ed3c1';

@ProviderFor(simpleFinAccounts)
final simpleFinAccountsProvider = SimpleFinAccountsProvider._();

final class SimpleFinAccountsProvider extends $FunctionalProvider<
        AsyncValue<List<Account>?>, List<Account>?, FutureOr<List<Account>?>>
    with $FutureModifier<List<Account>?>, $FutureProvider<List<Account>?> {
  SimpleFinAccountsProvider._()
      : super(
          from: null,
          argument: null,
          retry: riverpodRetry,
          name: r'simpleFinAccountsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$simpleFinAccountsHash();

  @$internal
  @override
  $FutureProviderElement<List<Account>?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Account>?> create(Ref ref) {
    return simpleFinAccounts(ref);
  }
}

String _$simpleFinAccountsHash() => r'92df5f92bee28fb0f62714d1041d24a7ba280549';
