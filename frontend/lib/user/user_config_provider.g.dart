// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userConfigApi)
const userConfigApiProvider = UserConfigApiProvider._();

final class UserConfigApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserConfigApi>,
          UserConfigApi,
          FutureOr<UserConfigApi>
        >
    with $FutureModifier<UserConfigApi>, $FutureProvider<UserConfigApi> {
  const UserConfigApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userConfigApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userConfigApiHash();

  @$internal
  @override
  $FutureProviderElement<UserConfigApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserConfigApi> create(Ref ref) {
    return userConfigApi(ref);
  }
}

String _$userConfigApiHash() => r'3fb676f40219a1c1f2dea6580987defebea3d62b';

@ProviderFor(packageInfo)
const packageInfoProvider = PackageInfoProvider._();

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  const PackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'44d37547139567a5f03c1942c1d62ff1abb07248';

@ProviderFor(UserConfigNotifier)
const userConfigProvider = UserConfigNotifierProvider._();

final class UserConfigNotifierProvider
    extends $AsyncNotifierProvider<UserConfigNotifier, UserConfig?> {
  const UserConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userConfigNotifierHash();

  @$internal
  @override
  UserConfigNotifier create() => UserConfigNotifier();
}

String _$userConfigNotifierHash() =>
    r'793cd3dbd0b609ea1a33430b38a879c2a9a736ab';

abstract class _$UserConfigNotifier extends $AsyncNotifier<UserConfig?> {
  FutureOr<UserConfig?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UserConfig?>, UserConfig?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserConfig?>, UserConfig?>,
              AsyncValue<UserConfig?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
