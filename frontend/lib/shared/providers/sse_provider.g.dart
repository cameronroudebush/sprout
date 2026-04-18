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

String _$sseHash() => r'c28d8f13c5b70e24aa91d71177e4937e394197a2';

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
