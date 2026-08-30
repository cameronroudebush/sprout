// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State for chat API

@ProviderFor(chatApi)
final chatApiProvider = ChatApiProvider._();

/// State for chat API

final class ChatApiProvider
    extends $FunctionalProvider<AsyncValue<ChatApi>, ChatApi, FutureOr<ChatApi>>
    with $FutureModifier<ChatApi>, $FutureProvider<ChatApi> {
  /// State for chat API
  ChatApiProvider._()
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
final chatProvider = ChatProvider._();

/// State for the chat elements
final class ChatProvider
    extends $AsyncNotifierProvider<Chat, List<ChatHistory>> {
  /// State for the chat elements
  ChatProvider._()
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

String _$chatHash() => r'6ac4d9de4996df3fedf9fc8dbca9b5ac9e4b82d8';

/// State for the chat elements

abstract class _$Chat extends $AsyncNotifier<List<ChatHistory>> {
  FutureOr<List<ChatHistory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ChatHistory>>, List<ChatHistory>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ChatHistory>>, List<ChatHistory>>,
        AsyncValue<List<ChatHistory>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Fetches the daily financial overview status for the dashboard

@ProviderFor(chatStatus)
final chatStatusProvider = ChatStatusFamily._();

/// Fetches the daily financial overview status for the dashboard

final class ChatStatusProvider extends $FunctionalProvider<
        AsyncValue<ChatOverview?>, ChatOverview?, FutureOr<ChatOverview?>>
    with $FutureModifier<ChatOverview?>, $FutureProvider<ChatOverview?> {
  /// Fetches the daily financial overview status for the dashboard
  ChatStatusProvider._(
      {required ChatStatusFamily super.from,
      required ChatOverviewTypeEnum super.argument})
      : super(
          retry: null,
          name: r'chatStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatStatusHash();

  @override
  String toString() {
    return r'chatStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChatOverview?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChatOverview?> create(Ref ref) {
    final argument = this.argument as ChatOverviewTypeEnum;
    return chatStatus(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatStatusHash() => r'f6a95eb23695e4f130f5b8130bd04d2c0e382c9f';

/// Fetches the daily financial overview status for the dashboard

final class ChatStatusFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<ChatOverview?>,
            ChatOverviewTypeEnum> {
  ChatStatusFamily._()
      : super(
          retry: null,
          name: r'chatStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches the daily financial overview status for the dashboard

  ChatStatusProvider call(
    ChatOverviewTypeEnum type,
  ) =>
      ChatStatusProvider._(argument: type, from: this);

  @override
  String toString() => r'chatStatusProvider';
}

/// Provides whether AI Chat capabilities are enabled based on both
/// secure server configuration and user settings.

@ProviderFor(chatEnabled)
final chatEnabledProvider = ChatEnabledProvider._();

/// Provides whether AI Chat capabilities are enabled based on both
/// secure server configuration and user settings.

final class ChatEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provides whether AI Chat capabilities are enabled based on both
  /// secure server configuration and user settings.
  ChatEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return chatEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$chatEnabledHash() => r'960af24d05e96a8dd87ae3d8d9ebdb35d73275af';
