import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';

/// A notification widget that displays the given notification in a pretty format
class NotificationItem extends StatelessWidget {
  final Notification notification;
  final bool showDate;

  /// Shows the unread indicator if set in notification. If this is false and the notification is unread, it won't display such.
  final bool showUnreadIndicator;

  /// If an indicator that something is in process should be shown
  final bool showSpinner;

  const NotificationItem(
    this.notification, {
    super.key,
    this.showDate = true,
    this.showUnreadIndicator = true,
    this.showSpinner = false,
  });

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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          // Type Icon
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              if (showSpinner)
                SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: color)),
            ],
          ),

          // Text Content
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: showUnreadIndicator && !notification.isRead ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    // Title
                    Flexible(
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
                    if (showUnreadIndicator && !notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                  ],
                ),
                // Message
                if (notification.message != "")
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                if (showDate)
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
