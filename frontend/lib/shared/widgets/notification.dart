import 'package:flutter/material.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// A widget that is used to display a [SproutNotification]
class SproutNotificationWidget extends StatelessWidget {
  final SproutNotification notification;

  /// If we should be allowed to render this notification in more than one line
  final bool allowMultiLine;

  const SproutNotificationWidget(this.notification, {super.key, this.allowMultiLine = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return SproutCard(
        bgColor: notification.bgColor,
        borderColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: InkWell(
            onTap: notification.onClick,
            child: Row(
              spacing: 8,
              children: [
                if (notification.icon != null) Icon(notification.icon, color: notification.color),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        notification.message,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: notification.color,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: allowMultiLine ? 5 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (notification.onClick != null) Icon(Icons.chevron_right, color: notification.color),
              ],
            ),
          ),
        ),
      );
    });
  }
}
