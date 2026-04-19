// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Defines an SSE riverpod that tracks our current SSE info

@ProviderFor(Sse)
final sseProvider = SseProvider._();

/// Defines an SSE riverpod that tracks our current SSE info
final class SseProvider extends $NotifierProvider<Sse, SseConnectionState> {
  /// Defines an SSE riverpod that tracks our current SSE info
  SseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sseHash();

  @$internal
  @override
  Sse create() => Sse();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SseConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SseConnectionState>(value),
    );
  }
}

String _$sseHash() => r'79f37c0f0b8cd091eb67bc50c4d3d0b404e13d44';

/// Defines an SSE riverpod that tracks our current SSE info

abstract class _$Sse extends $Notifier<SseConnectionState> {
  SseConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SseConnectionState, SseConnectionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SseConnectionState, SseConnectionState>,
        SseConnectionState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
