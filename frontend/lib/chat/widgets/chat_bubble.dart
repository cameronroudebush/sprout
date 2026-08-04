import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/chat/widgets/chat_message_content.dart';
import 'package:sprout/chat/widgets/chat_typing_indicator.dart';
import 'package:sprout/shared/widgets/icon.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/user/widgets/user_avatar.dart';

/// A widget that provides a chat bubble.
class ChatBubble extends ConsumerWidget {
  final ChatHistory message;
  final bool displayThinking;

  const ChatBubble({super.key, required this.message, this.displayThinking = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider).value;
    final bool isAi = message.role == ChatHistoryRoleEnum.model;

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
                    child: message.isThinking
                        ? displayThinking
                            ? const TypingIndicator()
                            : const SizedBox.shrink()
                        : ChatMessageContent(
                            text: message.text,
                            isAi: isAi,
                            textColor: Colors.white,
                          ),
                  ),
                ),
              ),

              // Current User Avatar
              if (!isAi) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8),
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
