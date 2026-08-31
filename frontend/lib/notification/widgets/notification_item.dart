import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';

/// A notification widget that displays the given notification in a pretty format
class NotificationItem extends StatelessWidget {
  final Notification notification;
  final bool showDate;

  /// Shows the unread indicator if set in notification. If this is false and the notification is unread, it won't display such.
  final bool showUnreadIndicator;

  /// If an indicator that something is in process should be shown
  final bool showSpinner;

  /// If this is a floating indicator that is singular
  final bool isFloating;

  const NotificationItem(
    this.notification, {
    super.key,
    this.showDate = true,
    this.showUnreadIndicator = true,
    this.showSpinner = false,
    this.isFloating = false,
  });

  /// Opens a dialog to show the notification on tap
  void onTap(BuildContext context) {
    showSproutPopup(
      context: context,
      builder: (ctx) => SproutBaseDialogWidget(
        notification.title,
        showCloseDialogButton: true,
        showSubmitButton: false,
        child: Text(
          notification.message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, color) = switch (notification.type) {
      NotificationTypeEnum.success => (Icons.check_circle_outline, Colors.green),
      NotificationTypeEnum.warning => (Icons.warning_amber_rounded, Colors.orange),
      NotificationTypeEnum.error => (Icons.error_outline_rounded, Colors.red),
      _ => (Icons.info_outline_rounded, theme.colorScheme.primary),
    };

    final borderRadius = isFloating ? BorderRadius.circular(12) : BorderRadius.zero;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: notification.isRead ? null : color.withValues(alpha: 0.05),
          borderRadius: borderRadius,
        ),
        child: InkWell(
          onTap: () => onTap(context),
          borderRadius: borderRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: (isFloating && showUnreadIndicator && !notification.isRead) ? 28 : 16,
                ),
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
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: color,
                            ),
                          ),
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
                            mainAxisSize: isFloating ? MainAxisSize.min : MainAxisSize.max,
                            children: [
                              Flexible(
                                child: Text(
                                  notification.title,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                              if (!isFloating && showUnreadIndicator && !notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          if (notification.message.isNotEmpty)
                            Text(
                              notification.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (showDate)
                            Text(
                              DateFormat('MM-dd-yyyy').format(notification.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isFloating && showUnreadIndicator && !notification.isRead)
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
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
