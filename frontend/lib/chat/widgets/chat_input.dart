import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/chat/models/extensions/chat_time_frame_extensions.dart';
import 'package:sprout/chat/widgets/mention_controller.dart';
import 'package:sprout/config/config_provider.dart';

/// The input component that allows the user to specify the message to send to the AI
/// with additional handling for mentions and timeframe context selection.
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
  ChatRequestDTOTimeframeEnum _selectedTimeframe = ChatRequestDTOTimeframeEnum.threeMonths;

  @override
  void initState() {
    super.initState();
    _controller = MentionController(idToNameMap: {});
    _controller.addListener(_handleMentionDeletion);
    _controller.addListener(_onTextChanged);
  }

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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.cardTheme.color,
                border: Border.all(width: 2, color: theme.dividerColor),
              ),
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
                        leading: AccountIcon(item),
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
  void _send() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await ref.read(chatProvider.notifier).sendMessage(text, timeframe: _selectedTimeframe);
      _controller.clear();
      _hideMentionPopup();
    }
  }

  /// Builds quick actions to allow the user to get quick responses without typing.
  /// Sends the action using the currently selected context timeframe.
  Widget _buildQuickActions(bool isDemoMode) {
    if (isDemoMode) return const SizedBox.shrink();

    final List<Map<String, String>> suggestions = [
      {'title': "Spending", 'message': "Analyze my spending patterns for the entire period of data."},
      {'title': "Net Worth", 'message': "Analyze my net worth trend for the entire period of data."},
      {'title': "Suggestions", 'message': "Give me some ideas on how to further improve my financial health."},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: suggestions
              .map((s) => Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: ActionChip(
                      label: Text(s['title']!),
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              // Send message utilizing the selected timeframe
                              ref.read(chatProvider.notifier).sendMessage(s['message']!, timeframe: _selectedTimeframe);
                            },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDemoMode = ref.watch(unsecureConfigProvider.notifier).isDemoMode();
    final accounts = ref.watch(accountsProvider).value?.accounts ?? [];
    for (var acc in accounts) {
      _controller.idToNameMap[acc.id] = acc.name;
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            _buildQuickActions(isDemoMode),

            // Text Input, Context Window Selector, and Send Button
            Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.isLoading && !isDemoMode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Ask Sprout anything...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                if (!isDemoMode)
                  PopupMenuButton<ChatRequestDTOTimeframeEnum>(
                    enabled: !widget.isLoading,
                    tooltip: "Historical context duration",
                    initialValue: _selectedTimeframe,
                    menuPadding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    onSelected: (ChatRequestDTOTimeframeEnum timeframe) {
                      setState(() {
                        _selectedTimeframe = timeframe;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => ChatRequestDTOTimeframeEnum.values.map((timeframe) {
                      final isSelected = timeframe == _selectedTimeframe;
                      return PopupMenuItem<ChatRequestDTOTimeframeEnum>(
                        value: timeframe,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  timeframe.longLabel,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.colorScheme.primary : null,
                                  ),
                                ),
                                if (isSelected) Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
                              ],
                            ),
                            Text(
                              timeframe.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedTimeframe.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isDemoMode)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FloatingActionButton(
                      onPressed: widget.isLoading ? null : _send,
                      child: widget.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send, size: 24),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
