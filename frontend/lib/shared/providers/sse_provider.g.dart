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
final class SseProvider extends $StreamNotifierProvider<Sse, SSEData> {
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
}

String _$sseHash() => r'333571f23f2f10091959ff77b2713f45361d8c17';

/// Defines an SSE riverpod that tracks our current SSE info

abstract class _$Sse extends $StreamNotifier<SSEData> {
  Stream<SSEData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SSEData>, SSEData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SSEData>, SSEData>,
              AsyncValue<SSEData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
