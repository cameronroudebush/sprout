// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the UserApi with the correct base path automatically.

@ProviderFor(userApi)
final userApiProvider = UserApiProvider._();

/// Provides the UserApi with the correct base path automatically.

final class UserApiProvider
    extends $FunctionalProvider<AsyncValue<UserApi>, UserApi, FutureOr<UserApi>>
    with $FutureModifier<UserApi>, $FutureProvider<UserApi> {
  /// Provides the UserApi with the correct base path automatically.
  UserApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userApiHash();

  @$internal
  @override
  $FutureProviderElement<UserApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserApi> create(Ref ref) {
    return userApi(ref);
  }
}

String _$userApiHash() => r'b53ee061bf63e1f106148d3bd9a6754538ca43cd';

/// Manages User-related actions like device registration.

@ProviderFor(UserNotifier)
final userProvider = UserNotifierProvider._();

/// Manages User-related actions like device registration.
final class UserNotifierProvider extends $NotifierProvider<UserNotifier, void> {
  /// Manages User-related actions like device registration.
  UserNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userNotifierHash();

  @$internal
  @override
  UserNotifier create() => UserNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$userNotifierHash() => r'f2d19a12bbdcdefae84f937aff6d5081ee768dfe';

/// Manages User-related actions like device registration.

abstract class _$UserNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
