// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WidgetSync)
const widgetSyncProvider = WidgetSyncProvider._();

final class WidgetSyncProvider extends $NotifierProvider<WidgetSync, void> {
  const WidgetSyncProvider._()
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$widgetSyncHash() => r'42e9fda07ffb1d63203c2319b988abcba499bbc0';

abstract class _$WidgetSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
