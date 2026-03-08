import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';

part 'chat_provider.g.dart';

/// State for chat API
@Riverpod(keepAlive: true)
Future<ChatApi> chatApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return ChatApi(client);
}

/// State for the chat elements
@Riverpod(keepAlive: true)
class Chat extends _$Chat {
  @override
  Future<List<ChatHistory>> build() async {
    ref.listen(sseProvider, (prev, next) {
      final data = next.value;
      if (data?.event == SSEDataEventEnum.chat) {
        final chat = ChatHistory.fromJson(data?.payload);
        if (chat != null) {
          _updateMessage(chat);
        }
      }
    });

    final api = await ref.watch(chatApiProvider.future);
    final history = await api.chatControllerHistory() ?? [];

    // Sort by latest first
    return history..sort((a, b) => b.time.compareTo(a.time));
  }

  /// Handles inserting a new message or updating an existing one
  void _updateMessage(ChatHistory chat) {
    if (state.value == null) return;

    final messages = [...state.value!];
    final index = messages.indexWhere((m) => m.id == chat.id);

    if (index == -1) {
      messages.insert(0, chat);
    } else {
      messages[index] = chat;
    }

    state = AsyncData(messages);
  }

  /// Sends a message to the backend
  Future<void> sendMessage(String message) async {
    final api = await ref.read(chatApiProvider.future);

    await api.chatControllerNew(ChatRequestDTO(message: message));
  }

  /// Clears chat state
  void clear() => state = const AsyncData([]);
}
