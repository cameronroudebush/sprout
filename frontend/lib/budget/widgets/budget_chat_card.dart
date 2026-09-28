import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/chat/widgets/chat_message_content.dart';
import 'package:sprout/chat/widgets/chat_model_indicator.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// Displays an AI-generated summary of budget performance.
class BudgetChatCard extends ConsumerWidget {
  final int year;
  final int month;

  const BudgetChatCard({super.key, required this.year, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(
      budgetChatStatusProvider((year: year, month: month)),
    );

    final content = overviewAsync.whenDefault(
      loadingText: 'Reviewing your budget...',
      expanded: false,
      customErrorMessage: 'Failed to load budget overview',
      emptyCondition: (overview) => overview == null || overview.text.trim().isEmpty,
      data: (overview) => Padding(
        padding: const EdgeInsets.all(8),
        child: ChatMessageContent(
          text: overview!.text,
          isAi: true,
          textColor: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );

    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SproutChartHeader(
            title: 'Budget Overview',
            subheader: 'Insights for ${DateFormat('MMMM yyyy').format(DateTime(year, month))}',
            left: const Tooltip(
              message: 'Powered by AI',
              child: Icon(Icons.auto_awesome),
            ),
            right: ChatModelIndicator(
              model: overviewAsync.value?.model,
              compact: true,
            ),
          ),
          content,
        ],
      ),
    );
  }
}
