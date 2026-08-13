import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/chat/widgets/chat_message_content.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// Renders the daily financial overview in a dashboard card
class DashboardDailyChatCard extends ConsumerWidget {
  /// Whether the widget is rendering on a mobile screen context
  final bool mobile;

  const DashboardDailyChatCard({super.key, this.mobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStatusAsync = ref.watch(chatStatusProvider(ChatOverviewTypeEnum.accounts));

    Widget content = chatStatusAsync.whenDefault(
      loadingText: "Asking Sprout for an overview...",
      expanded: false,
      customErrorMessage: "Failed to load daily overview",
      emptyCondition: (status) => status == null || status.text.trim().isEmpty,
      data: (status) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatMessageContent(
              text: status!.text,
              isAi: true,
              textColor: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        );
      },
    );

    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: mobile ? MainAxisSize.min : MainAxisSize.max,
        spacing: 4,
        children: [
          SproutChartHeader(
              title: "Daily Overview",
              subheader: "Based on last synced data",
              left: Row(
                children: [
                  Tooltip(
                    message: "Powered by AI",
                    child: Icon(Icons.auto_awesome),
                  )
                ],
              )),
          mobile ? content : Expanded(child: content),
        ],
      ),
    );
  }
}
