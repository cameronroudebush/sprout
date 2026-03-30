import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/chat/widgets/mention_controller.dart';

/// The input component that allows the user to specify the message to send to the AI
///   with some additional handlings added to it
class ChatInput extends ConsumerStatefulWidget {
  final bool isLoading;

  const ChatInput({super.key, required this.isLoading});

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  late MentionController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _lastText = "";

  @override
  void initState() {
    super.initState();
    _controller = MentionController(idToNameMap: {});
    _controller.addListener(_handleMentionDeletion);
    _controller.addListener(_onTextChanged);
  }

  /// Handles what to do when we remove a mention in the inputs
  void _handleMentionDeletion() {
    final currentText = _controller.text;
    final selection = _controller.selection;

    if (currentText.length < _lastText.length && selection.isCollapsed) {
      final pattern = RegExp(r'@\S+');
      final matches = pattern.allMatches(_lastText);

      for (final match in matches) {
        if (selection.baseOffset > match.start && selection.baseOffset < match.end) {
          final newText = _lastText.replaceRange(match.start, match.end, "");
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: match.start),
          );
          break;
        }
      }
    }
    _lastText = _controller.text;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hideMentionPopup();
    _controller.dispose();
    super.dispose();
  }

  /// Handles what to do when the text changes, notable to handle the popups
  void _onTextChanged() {
    final text = _controller.text;
    final selection = _controller.selection;
    if (selection.baseOffset <= 0) {
      _hideMentionPopup();
      return;
    }

    final charBeforeCursor = text[selection.baseOffset - 1];
    if (charBeforeCursor == '@') {
      _showMentionPopup();
    } else {
      _hideMentionPopup();
    }
  }

  /// Shows the mention popup so you can reference specific accounts
  void _showMentionPopup() {
    final theme = Theme.of(context);
    // Hide any other popup
    _hideMentionPopup();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(20, -210),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(color: theme.cardTheme.color, border: BoxBorder.all(color: theme.dividerColor)),
              child: Consumer(
                builder: (context, ref, _) {
                  final items = ref.watch(accountsProvider).value?.accounts ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        dense: true,
                        leading: AccountLogo(item),
                        title: Text(item.name),
                        onTap: () => _applyMention(item),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Applies the mention from the popup to our current text so the system can identify it during de-identification
  void _applyMention(Account item) {
    _controller.idToNameMap[item.id] = item.name;

    final text = _controller.text;
    final selection = _controller.selection;
    final lastAtIndex = text.lastIndexOf('@', selection.baseOffset - 1);

    if (lastAtIndex != -1) {
      final replacement = '@${item.id} ';
      final newText = text.replaceRange(lastAtIndex, selection.baseOffset, replacement);

      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: lastAtIndex + replacement.length),
      );
    }
    _hideMentionPopup();
    _focusNode.requestFocus();
    Future.microtask(() {
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  /// Hides the overlay that allows mentioning content
  void _hideMentionPopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Sends our message to the AI for processing
  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _controller.clear();
      _hideMentionPopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).value?.accounts ?? [];
    for (var acc in accounts) {
      _controller.idToNameMap[acc.id] = acc.name;
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isLoading,
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
              onPressed: widget.isLoading ? null : _send,
              child: widget.isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
