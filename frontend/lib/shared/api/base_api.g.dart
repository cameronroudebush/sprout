// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes

@ProviderFor(baseApiClient)
const baseApiClientProvider = BaseApiClientProvider._();

/// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes

final class BaseApiClientProvider
    extends
        $FunctionalProvider<
          AsyncValue<ApiClient>,
          ApiClient,
          FutureOr<ApiClient>
        >
    with $FutureModifier<ApiClient>, $FutureProvider<ApiClient> {
  /// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes
  const BaseApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'baseApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$baseApiClientHash();

  @$internal
  @override
  $FutureProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ApiClient> create(Ref ref) {
    return baseApiClient(ref);
  }
}

String _$baseApiClientHash() => r'be3991511c9d76a94cf8edee6c6c8ec682e737ed';

/// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]

@ProviderFor(baseAuthenticatedClient)
const baseAuthenticatedClientProvider = BaseAuthenticatedClientProvider._();

/// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]

final class BaseAuthenticatedClientProvider
    extends
        $FunctionalProvider<
          AsyncValue<ApiClient>,
          ApiClient,
          FutureOr<ApiClient>
        >
    with $FutureModifier<ApiClient>, $FutureProvider<ApiClient> {
  /// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]
  const BaseAuthenticatedClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'baseAuthenticatedClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$baseAuthenticatedClientHash();

  @$internal
  @override
  $FutureProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ApiClient> create(Ref ref) {
    return baseAuthenticatedClient(ref);
  }
}

String _$baseAuthenticatedClientHash() =>
    r'3df420d6f0468dad0c2b5d4c85e3fd135da6c4c8';
