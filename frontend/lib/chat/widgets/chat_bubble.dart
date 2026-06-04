import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/chat/models/extensions/chat_history_extensions.dart';
import 'package:sprout/chat/widgets/chat_typing_indicator.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/icon.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/widgets/user_avatar.dart';

/// A widget that provides a chat bubble. Useful to display when the LLM is thinking.
class ChatBubble extends ConsumerWidget {
  final ChatHistory message;

  const ChatBubble({super.key, required this.message});

  /// Renders the message data using GPT markdown
  Widget _getGPTMarkdown(BuildContext context, WidgetRef ref, bool isAi) {
    final userConfigAsync = ref.watch(userConfigProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    // If accounts are still loading, don't render the text yet to avoid flashing raw IDs
    return accountsAsync.when(
      loading: () => const TypingIndicator(),
      error: (err, _) => Text("Error: $err", style: const TextStyle(color: Colors.white)),
      data: (accountState) {
        final isPrivate = userConfigAsync.value?.privateMode ?? false;
        final accounts = accountState.accounts;
        String processedText = message.text;
        processedText = processedText.deIdentifyAccounts(accounts);
        final finalText = isPrivate ? processedText.deIdentifyCurrency() : processedText;
        final textColor = isAi ? Colors.white : Colors.white;

        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              headlineLarge: TextStyle(color: textColor, fontSize: 22),
              headlineMedium: TextStyle(color: textColor, fontSize: 20),
              headlineSmall: TextStyle(color: textColor, fontSize: 18),
              titleLarge: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          child: GptMarkdown(finalText, style: TextStyle(color: textColor, fontSize: 14)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider).value;
    bool isAi = message.role == ChatHistoryRoleEnum.model;

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Align(
        alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI Avatar
              if (isAi) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const SproutIcon(24),
                ),
              ],

              // The Chat Bubble
              Flexible(
                  child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? (constraints.maxWidth * 0.7).clamp(0.0, 800.0) : constraints.maxWidth * 0.75,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAi ? theme.colorScheme.secondary : theme.colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: isAi ? Radius.zero : const Radius.circular(15),
                      bottomRight: isAi ? const Radius.circular(15) : Radius.zero,
                    ),
                  ),
                  child: message.isThinking ? const TypingIndicator() : _getGPTMarkdown(context, ref, isAi),
                ),
              )),

              // Current User Avatar
              if (!isAi) ...[
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: UserAvatar(auth),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
