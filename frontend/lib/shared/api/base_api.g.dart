// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Root client to use with every other client

@ProviderFor(rootHttpClient)
final rootHttpClientProvider = RootHttpClientProvider._();

/// Root client to use with every other client

final class RootHttpClientProvider extends $FunctionalProvider<
        AsyncValue<http.Client>, http.Client, FutureOr<http.Client>>
    with $FutureModifier<http.Client>, $FutureProvider<http.Client> {
  /// Root client to use with every other client
  RootHttpClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rootHttpClientProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rootHttpClientHash();

  @$internal
  @override
  $FutureProviderElement<http.Client> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<http.Client> create(Ref ref) {
    return rootHttpClient(ref);
  }
}

String _$rootHttpClientHash() => r'cc445fa11f61ed1320626087d2898d7653928f41';

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

String _$baseApiClientHash() => r'c4e7a9f6e880339dfcd0a0e6017bb9371a4b9608';

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
    r'fc6f3f2cfc29195c9450dd5d06647deae8f454d6';
