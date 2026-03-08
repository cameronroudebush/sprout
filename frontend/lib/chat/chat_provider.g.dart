// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State for chat API

@ProviderFor(chatApi)
const chatApiProvider = ChatApiProvider._();

/// State for chat API

final class ChatApiProvider
    extends $FunctionalProvider<AsyncValue<ChatApi>, ChatApi, FutureOr<ChatApi>>
    with $FutureModifier<ChatApi>, $FutureProvider<ChatApi> {
  /// State for chat API
  const ChatApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatApiHash();

  @$internal
  @override
  $FutureProviderElement<ChatApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChatApi> create(Ref ref) {
    return chatApi(ref);
  }
}

String _$chatApiHash() => r'57b1815bf49e6d920c3fc51dbaa6a034d0a110e1';

/// State for the chat elements

@ProviderFor(Chat)
const chatProvider = ChatProvider._();

/// State for the chat elements
final class ChatProvider
    extends $AsyncNotifierProvider<Chat, List<ChatHistory>> {
  /// State for the chat elements
  const ChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatHash();

  @$internal
  @override
  Chat create() => Chat();
}

String _$chatHash() => r'566cf767144966511ce3581ab9e0613d0ae21696';

/// State for the chat elements

abstract class _$Chat extends $AsyncNotifier<List<ChatHistory>> {
  FutureOr<List<ChatHistory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ChatHistory>>, List<ChatHistory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ChatHistory>>, List<ChatHistory>>,
              AsyncValue<List<ChatHistory>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
