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

String _$widgetSyncHash() => r'8bb32a07114788fdac6cf33e16fc0fbb11abbf83';

abstract class _$WidgetSync extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
