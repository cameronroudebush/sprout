// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_time_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SproutSplashManager)
final sproutSplashManagerProvider = SproutSplashManagerProvider._();

final class SproutSplashManagerProvider
    extends $AsyncNotifierProvider<SproutSplashManager, bool> {
  SproutSplashManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sproutSplashManagerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sproutSplashManagerHash();

  @$internal
  @override
  SproutSplashManager create() => SproutSplashManager();
}

String _$sproutSplashManagerHash() =>
    r'c128d430b1f10e5fdd014511f7ec9f237b715446';

abstract class _$SproutSplashManager extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<bool>, bool>,
        AsyncValue<bool>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
