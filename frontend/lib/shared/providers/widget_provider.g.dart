// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WidgetSync)
final widgetSyncProvider = WidgetSyncProvider._();

final class WidgetSyncProvider
    extends $AsyncNotifierProvider<WidgetSync, void> {
  WidgetSyncProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'widgetSyncProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$widgetSyncHash();

  @$internal
  @override
  WidgetSync create() => WidgetSync();
}

String _$widgetSyncHash() => r'520731e04402bb7aa02a623e2aaae6908e879ca8';

abstract class _$WidgetSync extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
