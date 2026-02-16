import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// This provider handles communication and common functions for LLM prompting to the backend
class ChatProvider extends BaseProvider<ChatApi> {
  List<ChatHistory> _messages = [];

  // Public getters
  List<ChatHistory> get messages => _messages;

  ChatProvider(super.api);

  /// Populates the previous chat messages
  Future<List<ChatHistory>?> populateHistory() async {
    await populateAndSetIfChanged(
      api.chatControllerHistory,
      _messages,
      (newValue) => _messages = List.from(newValue ?? []),
    );
    return _messages;
  }

  /// Initiates a new prompt to the LLM through the backend
  Future<void> sendMessage(String message) async {
    await api.chatControllerNew(ChatRequestDTO(message: message));
  }

  @override
  Future<void> onSSE(SSEData data) async {
    if (data.event == SSEDataEventEnum.chat) {
      final chat = ChatHistory.fromJson(data.payload);
      if (chat != null) {
        // Replace the history
        int index = _messages.indexWhere((item) => item.id == chat.id);
        if (index == -1) {
          _messages.insert(0, chat);
        } else {
          _messages[index] = chat;
        }
        notifyListeners();
      }
    }
  }

  @override
  Future<void> postLogin() async {
    await populateHistory();
  }
}
