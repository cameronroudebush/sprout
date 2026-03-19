// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes

@ProviderFor(baseApiClient)
final baseApiClientProvider = BaseApiClientProvider._();

/// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes

final class BaseApiClientProvider extends $FunctionalProvider<
        AsyncValue<ApiClient>, ApiClient, FutureOr<ApiClient>>
    with $FutureModifier<ApiClient>, $FutureProvider<ApiClient> {
  /// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes
  BaseApiClientProvider._()
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

String _$baseApiClientHash() => r'fcaef499b4440258536d440a04856c03fb048cb6';

/// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]

@ProviderFor(baseAuthenticatedClient)
final baseAuthenticatedClientProvider = BaseAuthenticatedClientProvider._();

/// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]

final class BaseAuthenticatedClientProvider extends $FunctionalProvider<
        AsyncValue<ApiClient>, ApiClient, FutureOr<ApiClient>>
    with $FutureModifier<ApiClient>, $FutureProvider<ApiClient> {
  /// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]
  BaseAuthenticatedClientProvider._()
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
    r'73e930cbbde316a40a429563e18c1f73f12ad757';
