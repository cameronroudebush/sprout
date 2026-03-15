// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the authApi configured with the proper base path

@ProviderFor(authApi)
const authApiProvider = AuthApiProvider._();

/// Returns the authApi configured with the proper base path

final class AuthApiProvider
    extends $FunctionalProvider<AsyncValue<AuthApi>, AuthApi, FutureOr<AuthApi>>
    with $FutureModifier<AuthApi>, $FutureProvider<AuthApi> {
  /// Returns the authApi configured with the proper base path
  const AuthApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authApiHash();

  @$internal
  @override
  $FutureProviderElement<AuthApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AuthApi> create(Ref ref) {
    return authApi(ref);
  }
}

String _$authApiHash() => r'40eb50cd77ab1fe2a0880f2adda3de32db0bc69e';

@ProviderFor(Auth)
const authProvider = AuthProvider._();

final class AuthProvider extends $AsyncNotifierProvider<Auth, User?> {
  const AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();
}

String _$authHash() => r'b7f692e7d7774926c00da9c78d5fe469f71af100';

abstract class _$Auth extends $AsyncNotifier<User?> {
  FutureOr<User?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User?>, User?>,
              AsyncValue<User?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
