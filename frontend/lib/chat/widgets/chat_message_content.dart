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
class ChatMessageContent extends ConsumerWidget {
  final String text;
  final bool isAi;
  final Color? textColor;
  final bool showTypingWhenLoading;

  const ChatMessageContent(
      {super.key, required this.text, this.isAi = true, this.textColor, this.showTypingWhenLoading = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userConfigAsync = ref.watch(userConfigProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    // If accounts are still loading, don't render the text yet to avoid flashing raw IDs
    return accountsAsync.when(
      loading: () => showTypingWhenLoading ? const TypingIndicator() : const SizedBox.shrink(),
      error: (err, _) => Text("Error: $err", style: TextStyle(color: theme.colorScheme.error)),
      data: (accountState) {
        final isPrivate = userConfigAsync.value?.privateMode ?? false;
        final accounts = accountState.accounts;

        String processedText = text.deIdentifyAccounts(accounts);
        final finalText = isPrivate ? processedText.deIdentifyCurrency() : processedText;
        final effectiveColor = textColor ?? theme.textTheme.bodyMedium?.color ?? Colors.white;
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
    final chartRegex = RegExp(r'```chart\s*([\s\S]*?)\s*```');
    final matches = chartRegex.allMatches(text);

    // No charts so just return markdown
    if (matches.isEmpty || !parseCharts) return [GptMarkdown(text, style: style)];

    List<Widget> nodes = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add standard text before the chart
      final preText = text.substring(lastMatchEnd, match.start).trim();
      if (preText.isNotEmpty) nodes.add(GptMarkdown(preText, style: style));

      // Extract and parse the JSON chart data
      final jsonString = match.group(1)?.trim() ?? "{}";

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
        nodes.add(Text("Failed to load chart.", style: TextStyle(color: Colors.red)));
      }
      lastMatchEnd = match.end;
    }

    // Add remaining text
    final postText = text.substring(lastMatchEnd).trim();
    if (postText.isNotEmpty) nodes.add(GptMarkdown(postText, style: style));
    return nodes;
  }
}
