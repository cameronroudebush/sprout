import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';

/// A notification widget that displays the given notification in a pretty format
class NotificationItem extends StatelessWidget {
  final Notification notification;

  const NotificationItem(this.notification, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine icon and color based on type
    final (icon, color) = switch (notification.type) {
      NotificationTypeEnum.success => (Icons.check_circle_outline, Colors.green),
      NotificationTypeEnum.warning => (Icons.warning_amber_rounded, Colors.orange),
      NotificationTypeEnum.error => (Icons.error_outline_rounded, Colors.red),
      _ => (Icons.info_outline_rounded, theme.colorScheme.primary),
    };

    return Container(
      // Highlight unread notifications with a very subtle background tint
      color: notification.isRead ? null : color.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Type Icon
          Icon(icon, color: color, size: 20),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                    // Unread indicator
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                  ],
                ),
                // Message
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                // Date
                Text(
                  DateFormat('MM-dd-yyyy').format(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A helper to create a notification icon that can indicate if there is unread notifications
  static Widget buildNotificationIcon(bool hasUnread) {
    return Badge(
      isLabelVisible: hasUnread,
      padding: const EdgeInsets.all(4),
      backgroundColor: Colors.red,
      child: const Icon(Icons.notifications_none_rounded, size: 28),
    );
  }
}
