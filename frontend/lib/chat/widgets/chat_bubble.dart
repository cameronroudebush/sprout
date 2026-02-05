import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/chat/widgets/chat_typing_indicator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A widget that provides a chat bubble. Useful to display when the LLM is thinking.
class ChatBubble extends StatelessWidget {
  final ChatHistory message;

  const ChatBubble({super.key, required this.message});

  Widget _getGPTMarkdown(BuildContext context) {
    final isPrivate = ServiceLocator.get<UserConfigProvider>().currentUserConfig!.privateMode;

    final text = isPrivate ? replaceCurrency(message.text) : message.text;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
          // Override the specific header styles used by markdown
          headlineLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          headlineSmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      child: GptMarkdown(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine if the last message is from AI, used to trigger chat loading indication
    bool isAi = message.role == ChatHistoryRoleEnum.model;

    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(top: 4, bottom: 4, left: isAi ? 0 : 60, right: isAi ? 60 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAi ? theme.colorScheme.secondary : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: isAi ? Radius.zero : const Radius.circular(15),
            topRight: isAi ? const Radius.circular(15) : Radius.zero,
            bottomLeft: const Radius.circular(15),
            bottomRight: const Radius.circular(15),
          ),
        ),
        child: message.isThinking ? const TypingIndicator() : _getGPTMarkdown(context),
      ),
    );
  }
}
