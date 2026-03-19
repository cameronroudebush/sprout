// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentRoute)
final currentRouteProvider = CurrentRouteProvider._();

final class CurrentRouteProvider
    extends $NotifierProvider<CurrentRoute, String> {
  CurrentRouteProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentRouteProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentRouteHash();

  @$internal
  @override
  CurrentRoute create() => CurrentRoute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentRouteHash() => r'6709a4dc7456b6b3489986cb3eed304bece6634c';

abstract class _$CurrentRoute extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
