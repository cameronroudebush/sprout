import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/chat/widgets/chat_bubble.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Defines a the LLM communication page
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sends the current message
  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatAsync = ref.watch(chatProvider);
    final configAsync = ref.watch(secureConfigProvider);
    final userConfigAsync = ref.watch(userConfigProvider);

    return userConfigAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error loading config: $err")),
      data: (userConfig) {
        final bool llmConfigured =
            (configAsync.value?.chatKeyProvidedInBackend ?? false) || (userConfig?.geminiKey?.isNotEmpty ?? false);

        if (!llmConfigured) {
          return SproutRouteWrapper(child: _buildNoConfigState(theme));
        }

        return chatAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error loading chat: $err")),
          data: (messages) {
            final bool isLoading = messages.any((m) => m.isThinking);

            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? SproutRouteWrapper(child: _buildEmptyState(theme))
                      : Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return SproutRouteWrapper(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ChatBubble(message: messages[index]),
                              );
                            },
                          ),
                        ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
                  ),
                  child: SproutRouteWrapper(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        _buildQuickActions(isLoading),
                        _buildInputArea(isLoading),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Builds what to display when the AI isn't configured
  Widget _buildNoConfigState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Icon(Icons.auto_awesome_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
                Text(
                  "AI Assistant Not Configured",
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "To chat with Sprout and analyze your data, you'll need to provide an API key in your settings.",
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a widget to display when there is no LLM history
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SproutCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                "It's awfully quiet in here",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                "We haven't talked yet, but I'm ready when you are. Ask me a question below to kick things off. I promise I'm a great listener!",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds quick actions to allow the user to get quick responses without typing
  Widget _buildQuickActions(bool isLoading) {
    final List<Map<String, String>> suggestions = [
      {'title': "Spending", 'message': "Analyze my spending patterns."},
      {'title': "Net Worth", 'message': "Analyze my net worth trend."},
      {'title': "Suggestions", 'message': "Give me some ideas on how to further improve my financial health."},
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: suggestions
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ActionChip(
                  label: Text(s['title']!),
                  onPressed: isLoading ? null : () => ref.read(chatProvider.notifier).sendMessage(s['message']!),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Builds the input area for sending a custom message
  Widget _buildInputArea(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isLoading,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Ask Sprout anything...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
          FloatingActionButton(
            onPressed: isLoading ? null : _send,
            child: isLoading ? const CircularProgressIndicator() : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
