import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/chat/widgets/chat_bubble.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/user/user_config_provider.dart';

/// This component represents a chat that can be performed with an LLM to help analyze your current content
class Chat extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Chat({super.key});

  /// Sends the message to the provider
  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final provider = ServiceLocator.get<ChatProvider>();
      provider.sendMessage(text);
      _controller.clear();
    }
  }

  /// Returns if the chat provider has a message that is already thinking
  bool get _isLoading {
    return ServiceLocator.get<ChatProvider>().messages.where((element) => element.isThinking).isNotEmpty;
  }

  /// Returns if an LLM is configured or not
  bool get llmConfigured {
    final config = ServiceLocator.get<UserConfigProvider>().currentUserConfig;
    return config?.geminiKey != null && config!.geminiKey!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!llmConfigured) {
      return SproutCard(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: Column(
            spacing: 16,
            children: [
              Text(
                "No LLM is configured. Please set one in settings to proceed",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              FilledButton(onPressed: () => SproutNavigator.redirect("settings"), child: Text("Go to Settings")),
            ],
          ),
        ),
      );
    }

    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final messages = provider.messages;
        return Expanded(
          child: Column(
            spacing: 4,
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: SproutCard(
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 12,
                              children: [
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
                      )
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return ChatBubble(message: message);
                          },
                        ),
                      ),
              ),
              _buildQuickActions(provider),
              _buildInputArea(provider),
            ],
          ),
        );
      },
    );
  }

  /// Builds a list of quick actions so the user can quickly visualize how they are doing without typing their own message
  Widget _buildQuickActions(ChatProvider chatProvider) {
    // Suggestions on what we want to do
    final List<Map<String, String>> suggestions = [
      {'title': "Spending", 'message': "Analyze my spending patterns."},
      {'title': "Net Worth", 'message': "Analyze my net worth trend."},
      {'title': "Suggestions", 'message': "Give me some ideas on how to further improve my financial health."},
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        children: suggestions
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(s['title']!),
                  onPressed: _isLoading ? null : () => chatProvider.sendMessage(s['message']!),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Builds the input for the user to type into
  Widget _buildInputArea(ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isLoading,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Ask Sprout anything...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _send(),
            ),
          ),
          FloatingActionButton(
            onPressed: _isLoading ? null : _send,
            child: _isLoading ? CircularProgressIndicator() : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
