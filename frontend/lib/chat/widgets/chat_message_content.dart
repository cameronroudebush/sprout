import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/chat/models/extensions/chat_history_extensions.dart';
import 'package:sprout/chat/widgets/chat_typing_indicator.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Renders message text using GPT markdown with account and currency de-identification.
class ChatMessageContent extends ConsumerWidget {
  final String text;
  final bool isAi;
  final Color? textColor;

  const ChatMessageContent({
    super.key,
    required this.text,
    this.isAi = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userConfigAsync = ref.watch(userConfigProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    // If accounts are still loading, don't render the text yet to avoid flashing raw IDs
    return accountsAsync.when(
      loading: () => const TypingIndicator(),
      error: (err, _) => Text("Error: $err", style: TextStyle(color: theme.colorScheme.error)),
      data: (accountState) {
        final isPrivate = userConfigAsync.value?.privateMode ?? false;
        final accounts = accountState.accounts;

        String processedText = text.deIdentifyAccounts(accounts);
        final finalText = isPrivate ? processedText.deIdentifyCurrency() : processedText;
        final effectiveColor = textColor ?? theme.textTheme.bodyMedium?.color ?? Colors.white;

        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              headlineLarge: TextStyle(color: effectiveColor, fontSize: 22),
              headlineMedium: TextStyle(color: effectiveColor, fontSize: 20),
              headlineSmall: TextStyle(color: effectiveColor, fontSize: 18),
              titleLarge: TextStyle(color: effectiveColor, fontSize: 16),
            ),
          ),
          child: GptMarkdown(
            finalText,
            style: TextStyle(color: effectiveColor, fontSize: 14),
          ),
        );
      },
    );
  }
}
