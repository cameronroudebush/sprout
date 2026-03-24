import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/notification/widgets/notification_item.dart';

/// A widget that displays notification count alongside all notifications in a dropdown
class NotificationBell extends ConsumerWidget {
  final bool isDesktop;

  const NotificationBell({
    super.key,
    this.isDesktop = true,
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final notificationState = ref.watch(notificationsProvider);
    final notificationNotifier = ref.watch(notificationsProvider.notifier);
    final hasUnread = notificationNotifier.hasUnread;

    return PopupMenuButton<String>(
      color: theme.colorScheme.surface,
      onOpened: () => _handleNotificationMenuOpened(ref),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      offset: const Offset(0, 50),
      constraints: BoxConstraints(
        maxHeight: size.height * 0.4,
        maxWidth: isDesktop ? 520 : 340,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      child: isDesktop
          // Full button for desktop
          ? _buildSidebarButton(theme, hasUnread)
          // Just the icon for Mobile
          : Padding(
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

  /// Builds a sidebar version of the button
  Widget _buildSidebarButton(ThemeData theme, bool hasUnread) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: hasUnread ? theme.colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
        ),
        child: Row(
          spacing: 12,
          children: [
            NotificationItem.buildNotificationIcon(hasUnread),
            Expanded(
              child: Text(
                'Notifications',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
