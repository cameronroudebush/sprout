import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/chat/widgets/chat_bubble.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
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
    final messages = ref.watch(chatProvider).value ?? [];
    final userConfig = ref.watch(userConfigProvider).value;

    final bool isLoading = messages.any((m) => m.isThinking);
    final bool llmConfigured = userConfig?.geminiKey?.isNotEmpty ?? false;

    if (!llmConfigured) {
      return SproutCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 16,
            children: [
              const Text(
                "No LLM is configured. Please set one in settings to proceed",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              FilledButton(
                onPressed: () => NavigationProvider.redirect("/settings"),
                child: const Text("Go to Settings"),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      spacing: 4,
      children: [
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState()
              : Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => ChatBubble(message: messages[index]),
                  ),
                ),
        ),
        _buildQuickActions(isLoading),
        _buildInputArea(isLoading),
      ],
    );
  }

  /// Builds a widget to display when there is no LLM history
  Widget _buildEmptyState() {
    return Center(
      child: SproutCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: const [
              Text(
                "It's awfully quiet in here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "We haven't talked yet, but I'm ready when you are. Ask me a question below to kick things off. I promise I'm a great listener!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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
