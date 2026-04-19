// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the authApi configured with the proper base path

@ProviderFor(authApi)
final authApiProvider = AuthApiProvider._();

/// Returns the authApi configured with the proper base path

final class AuthApiProvider
    extends $FunctionalProvider<AsyncValue<AuthApi>, AuthApi, FutureOr<AuthApi>>
    with $FutureModifier<AuthApi>, $FutureProvider<AuthApi> {
  /// Returns the authApi configured with the proper base path
  AuthApiProvider._()
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

@ProviderFor(SessionStatus)
final sessionStatusProvider = SessionStatusProvider._();

final class SessionStatusProvider
    extends $NotifierProvider<SessionStatus, bool> {
  SessionStatusProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionStatusProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionStatusHash();

  @$internal
  @override
  SessionStatus create() => SessionStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sessionStatusHash() => r'70637bca7d1e5e2d92d7bf2519fdd2516b5e4dd4';

abstract class _$SessionStatus extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $AsyncNotifierProvider<Auth, User?> {
  AuthProvider._()
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

String _$authHash() => r'aeac2fc8d0374d0d5ddff3260cb957954181210f';

abstract class _$Auth extends $AsyncNotifier<User?> {
  FutureOr<User?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<User?>, User?>,
        AsyncValue<User?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Generic cookie jar to persist across app restarts for usage in mobile

@ProviderFor(cookieJar)
final cookieJarProvider = CookieJarFamily._();

/// Generic cookie jar to persist across app restarts for usage in mobile

final class CookieJarProvider extends $FunctionalProvider<AsyncValue<CookieJar>,
        CookieJar, FutureOr<CookieJar>>
    with $FutureModifier<CookieJar>, $FutureProvider<CookieJar> {
  /// Generic cookie jar to persist across app restarts for usage in mobile
  CookieJarProvider._(
      {required CookieJarFamily super.from, required bool super.argument})
      : super(
          retry: null,
          name: r'cookieJarProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cookieJarHash();

  @override
  String toString() {
    return r'cookieJarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CookieJar> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CookieJar> create(Ref ref) {
    final argument = this.argument as bool;
    return cookieJar(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CookieJarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cookieJarHash() => r'5c755cd4ef8139bc80f5a19215bb6594b8723486';

/// Generic cookie jar to persist across app restarts for usage in mobile

final class CookieJarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CookieJar>, bool> {
  CookieJarFamily._()
      : super(
          retry: null,
          name: r'cookieJarProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Generic cookie jar to persist across app restarts for usage in mobile

  CookieJarProvider call(
    bool persist,
  ) =>
      CookieJarProvider._(argument: persist, from: this);

  @override
  String toString() => r'cookieJarProvider';
}
