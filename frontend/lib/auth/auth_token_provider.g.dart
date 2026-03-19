// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Defines a riverpod that tracks all of our relevant tokens

@ProviderFor(AuthTokens)
final authTokensProvider = AuthTokensProvider._();

/// Defines a riverpod that tracks all of our relevant tokens
final class AuthTokensProvider
    extends $AsyncNotifierProvider<AuthTokens, SproutTokens> {
  /// Defines a riverpod that tracks all of our relevant tokens
  AuthTokensProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authTokensProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authTokensHash();

  @$internal
  @override
  AuthTokens create() => AuthTokens();
}

String _$authTokensHash() => r'93891fe3099d3e3372ea087e38965af9f4cfcec9';

/// Defines a riverpod that tracks all of our relevant tokens

abstract class _$AuthTokens extends $AsyncNotifier<SproutTokens> {
  FutureOr<SproutTokens> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SproutTokens>, SproutTokens>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SproutTokens>, SproutTokens>,
        AsyncValue<SproutTokens>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
