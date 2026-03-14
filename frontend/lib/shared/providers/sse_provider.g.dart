// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Defines an SSE riverpod that tracks our current SSE info

@ProviderFor(Sse)
const sseProvider = SseProvider._();

/// Defines an SSE riverpod that tracks our current SSE info
final class SseProvider extends $NotifierProvider<Sse, SseConnectionState> {
  /// Defines an SSE riverpod that tracks our current SSE info
  const SseProvider._()
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

String _$sseHash() => r'd2b576e925ef5ae9b19c07abf4bc229be9e71100';

/// Defines an SSE riverpod that tracks our current SSE info

abstract class _$Sse extends $Notifier<SseConnectionState> {
  SseConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SseConnectionState, SseConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SseConnectionState, SseConnectionState>,
              SseConnectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
