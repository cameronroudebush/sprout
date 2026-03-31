// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Future that produces the connection URL of the backend

@ProviderFor(connectionUrl)
final connectionUrlProvider = ConnectionUrlProvider._();

/// Future that produces the connection URL of the backend

final class ConnectionUrlProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Future that produces the connection URL of the backend
  ConnectionUrlProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectionUrlProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectionUrlHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return connectionUrl(ref);
  }
}

String _$connectionUrlHash() => r'ea696a98649748a5981c31d9adc9fbfb02f1c59d';

/// Future that produces the configuration API configured with the base path
/// DOES NOT HAVE AUTHENTICATION

@ProviderFor(configApi)
final configApiProvider = ConfigApiProvider._();

/// Future that produces the configuration API configured with the base path
/// DOES NOT HAVE AUTHENTICATION

final class ConfigApiProvider extends $FunctionalProvider<AsyncValue<ConfigApi>,
        ConfigApi, FutureOr<ConfigApi>>
    with $FutureModifier<ConfigApi>, $FutureProvider<ConfigApi> {
  /// Future that produces the configuration API configured with the base path
  /// DOES NOT HAVE AUTHENTICATION
  ConfigApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'configApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$configApiHash();

  @$internal
  @override
  $FutureProviderElement<ConfigApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ConfigApi> create(Ref ref) {
    return configApi(ref);
  }
}

String _$configApiHash() => r'd0e5f5a1ff813e6714c2877416349e80681ae54e';

/// Future that produces the configuration API configured with the base path and authentication

@ProviderFor(secureConfigApi)
final secureConfigApiProvider = SecureConfigApiProvider._();

/// Future that produces the configuration API configured with the base path and authentication

final class SecureConfigApiProvider extends $FunctionalProvider<
        AsyncValue<ConfigApi>, ConfigApi, FutureOr<ConfigApi>>
    with $FutureModifier<ConfigApi>, $FutureProvider<ConfigApi> {
  /// Future that produces the configuration API configured with the base path and authentication
  SecureConfigApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'secureConfigApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$secureConfigApiHash();

  @$internal
  @override
  $FutureProviderElement<ConfigApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ConfigApi> create(Ref ref) {
    return secureConfigApi(ref);
  }
}

String _$secureConfigApiHash() => r'd387c0157949e57747f86d1f477acfb8a1ab3b9c';

/// Extension upon unsecure config that allows state management using riverpod

@ProviderFor(UnsecureConfig)
final unsecureConfigProvider = UnsecureConfigProvider._();

/// Extension upon unsecure config that allows state management using riverpod
final class UnsecureConfigProvider
    extends $AsyncNotifierProvider<UnsecureConfig, UnsecureAppConfiguration?> {
  /// Extension upon unsecure config that allows state management using riverpod
  UnsecureConfigProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unsecureConfigProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unsecureConfigHash();

  @$internal
  @override
  UnsecureConfig create() => UnsecureConfig();
}

String _$unsecureConfigHash() => r'ee8aa5398ad51d009aa002886b4dc197aed1606d';

/// Extension upon unsecure config that allows state management using riverpod

abstract class _$UnsecureConfig
    extends $AsyncNotifier<UnsecureAppConfiguration?> {
  FutureOr<UnsecureAppConfiguration?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UnsecureAppConfiguration?>,
        UnsecureAppConfiguration?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UnsecureAppConfiguration?>,
            UnsecureAppConfiguration?>,
        AsyncValue<UnsecureAppConfiguration?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Extension upon secure config that allows state management using riverpod

@ProviderFor(SecureConfig)
final secureConfigProvider = SecureConfigProvider._();

/// Extension upon secure config that allows state management using riverpod
final class SecureConfigProvider
    extends $AsyncNotifierProvider<SecureConfig, APIConfig?> {
  /// Extension upon secure config that allows state management using riverpod
  SecureConfigProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'secureConfigProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$secureConfigHash();

  @$internal
  @override
  SecureConfig create() => SecureConfig();
}

String _$secureConfigHash() => r'91612664387396aaeac29f0280ea93d9d1c7b6e9';

/// Extension upon secure config that allows state management using riverpod

abstract class _$SecureConfig extends $AsyncNotifier<APIConfig?> {
  FutureOr<APIConfig?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<APIConfig?>, APIConfig?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<APIConfig?>, APIConfig?>,
        AsyncValue<APIConfig?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
