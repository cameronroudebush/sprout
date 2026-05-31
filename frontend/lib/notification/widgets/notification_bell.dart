import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/notification/widgets/notification_item.dart';

/// A widget that displays notification count alongside all notifications in a dropdown
class NotificationBell extends ConsumerWidget {
  const NotificationBell({
    super.key,
  });

  /// What to do when the popup menu is opened
  Future<void> _handleNotificationMenuOpened(WidgetRef ref) async {
    final notifier = ref.read(notificationsProvider.notifier);

    if (notifier.hasUnread) {
      final api = await ref.read(notificationApiProvider.future);
      await api.notificationControllerMarkAllRead();
      ref.invalidate(notificationsProvider);
    }

    notifier.clearAllOverlays();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final notificationState = ref.watch(notificationsProvider);
    final notificationNotifier = ref.watch(notificationsProvider.notifier);
    final hasUnread = notificationNotifier.hasUnread;

    return PopupMenuButton<String>(
      onOpened: () => _handleNotificationMenuOpened(ref),
      tooltip: "Show notifications",
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      offset: Offset(0, 50),
      constraints: BoxConstraints(
        maxHeight: size.height * 0.4,
        maxWidth: 340,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: NotificationItem.buildNotificationIcon(hasUnread),
      ),
      itemBuilder: (context) {
        return notificationState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return [
                const PopupMenuItem<String>(
                  enabled: false,
                  child: Center(child: Text('No notifications')),
                ),
              ];
            }
            return notifications
                .map((n) => PopupMenuItem<String>(
                      padding: EdgeInsets.zero,
                      child: NotificationItem(n),
                    ))
                .toList();
          },
          loading: () => [
            const PopupMenuItem(
              enabled: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          error: (err, _) => [
            const PopupMenuItem(
              enabled: false,
              child: Center(child: Text('Error loading notifications')),
            ),
          ],
        );
      },
    );
  }
}
