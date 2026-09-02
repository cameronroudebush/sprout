import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/chat/models/extensions/chat_history_extensions.dart';
import 'package:sprout/chat/widgets/charts/chat_line_chart.dart';
import 'package:sprout/chat/widgets/charts/chat_pie_chart.dart';
import 'package:sprout/chat/widgets/chat_typing_indicator.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Renders message text using GPT markdown with account and currency de-identification.
class ChatMessageContent extends ConsumerStatefulWidget {
  final String text;
  final bool isAi;
  final Color? textColor;
  final bool showTypingWhenLoading;

  const ChatMessageContent(
      {super.key, required this.text, this.isAi = true, this.textColor, this.showTypingWhenLoading = true});

  @override
  ConsumerState<ChatMessageContent> createState() => _ChatMessageContentState();
}

class _ChatMessageContentState extends ConsumerState<ChatMessageContent> {
  Timer? _timer;
  String _displayedText = '';
  String _targetText = '';

  @override
  void initState() {
    super.initState();
    _targetText = widget.text;

    // If it's not AI, or if text is already populated when mounted (historical messages), don't animate.
    if (!widget.isAi || widget.text.isNotEmpty) {
      _displayedText = widget.text;
    } else {
      _startTypingLoop();
    }
  }

  @override
  void didUpdateWidget(covariant ChatMessageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _targetText = widget.text;

      if (!widget.isAi) {
        _displayedText = widget.text;
      } else {
        _startTypingLoop();
      }
    }
  }

  void _startTypingLoop() {
    if (_timer?.isActive ?? false) return;

    // Increased timer interval slightly for smoother progression (20ms ≈ 50 fps)
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_displayedText.length < _targetText.length) {
        setState(() {
          // Detect any code block start early (as soon as ``` streams in)
          final openFence = _targetText.indexOf('```', _displayedText.length);
          if (openFence != -1 && openFence == _displayedText.length) {
            final closeFence = _targetText.indexOf('```', openFence + 3);
            if (closeFence != -1) {
              // Smoothly step through code blocks instead of jumping instantly
              _displayedText = _targetText.substring(0, (_displayedText.length + 5).clamp(0, closeFence + 3));
              return;
            } else {
              // Smoothly step towards end while fence remains unclosed
              _displayedText = _targetText.substring(0, (_displayedText.length + 5).clamp(0, _targetText.length));
              return;
            }
          }

          final diff = _targetText.length - _displayedText.length;
          // Capped maximum step size to prevent sudden text jumps
          final step = diff > 100 ? 2 : 1;
          final nextLength = (_displayedText.length + step).clamp(0, _targetText.length);
          _displayedText = _targetText.substring(0, nextLength);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userConfigAsync = ref.watch(userConfigProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    // If accounts are still loading, don't render the text yet to avoid flashing raw IDs
    return accountsAsync.when(
      loading: () => widget.showTypingWhenLoading ? const TypingIndicator() : const SizedBox.shrink(),
      error: (err, _) => Text("Error: $err", style: TextStyle(color: theme.colorScheme.error)),
      data: (accountState) {
        final isPrivate = userConfigAsync.value?.privateMode ?? false;
        final accounts = accountState.accounts;

        String processedText = _displayedText.deIdentifyAccounts(accounts);
        final finalText = isPrivate ? processedText.deIdentifyCurrency() : processedText;
        final effectiveColor = widget.textColor ?? theme.textTheme.bodyMedium?.color ?? Colors.white;
        final markdownStyle = TextStyle(color: effectiveColor, fontSize: 14);

        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              headlineLarge: TextStyle(color: effectiveColor, fontSize: 22),
              headlineMedium: TextStyle(color: effectiveColor, fontSize: 20),
              headlineSmall: TextStyle(color: effectiveColor, fontSize: 18),
              titleLarge: TextStyle(color: effectiveColor, fontSize: 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildContentNodes(finalText, markdownStyle),
          ),
        );
      },
    );
  }

  /// Splits the LLM response into Markdown text and Chart widgets as necessary
  ///
  /// [parseCharts] If we should parse charts into their actual chart objects versus leaving them as JSON
  List<Widget> _buildContentNodes(String text, TextStyle style, {bool parseCharts = true}) {
    // Detects ``` blocks early, including incomplete or partially typed opening tags
    final blockRegex = RegExp(r'```(?:chart)?\s*([\s\S]*?)(?:```|$)');
    final matches = blockRegex.allMatches(text);

    // No code/chart blocks so just return markdown
    if (matches.isEmpty || !parseCharts) return [GptMarkdown(text, style: style)];

    List<Widget> nodes = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add standard text before the block
      final preText = text.substring(lastMatchEnd, match.start).trim();
      if (preText.isNotEmpty) nodes.add(GptMarkdown(preText, style: style));

      final fullMatchText = match.group(0) ?? "";
      final jsonString = match.group(1)?.trim() ?? "";
      final isClosed = fullMatchText.endsWith('```');

      // If the triple-backtick block is unclosed or JSON is incomplete, immediately show a spinner
      if (!isClosed) {
        nodes.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
          ),
        );
      } else {
        try {
          final Map<String, dynamic> chartData = jsonDecode(jsonString);
          final chartType = chartData['type'] as String?;

          Widget chartWidget;
          switch (chartType) {
            case 'line':
              chartWidget = ChatSproutLineChart(chartData: chartData);
              break;
            case 'pie':
              chartWidget = ChatSproutPieChart(chartData: chartData);
              break;
            default:
              chartWidget = Text("Unsupported chart type: $chartType", style: TextStyle(color: Colors.red));
          }

          nodes.add(chartWidget);
        } catch (e) {
          // If JSON parsing fails on a closed block, check if it was intended as a chart
          if (fullMatchText.startsWith('```chart')) {
            nodes.add(Text("Failed to load chart.", style: TextStyle(color: Colors.red)));
          } else {
            // Standard non-chart markdown code block fallback
            nodes.add(GptMarkdown(fullMatchText, style: style));
          }
        }
      }
      lastMatchEnd = match.end;
    }

    // Add remaining text after the last match
    final postText = text.substring(lastMatchEnd).trim();
    if (postText.isNotEmpty) nodes.add(GptMarkdown(postText, style: style));
    return nodes;
  }
}
