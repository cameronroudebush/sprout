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
    r'7b0585f5e1a89f9396029b6bac7884bf987f1f37';

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
