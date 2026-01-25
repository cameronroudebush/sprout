import 'package:flutter/material.dart' hide Notification;
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/notification/firebase.dart';
import 'package:sprout/notification/widgets/notification_item.dart';

/// Class that provides the store of current net worth information
class NotificationProvider extends BaseProvider<NotificationApi> {
  List<Notification> _notifications = [];
  final List<OverlayEntry> _displayedNotifications = [];

  /// Public getters
  List<Notification> get notifications => _notifications;
  bool get hasUnread => _notifications.where((n) => !n.isRead).isNotEmpty;

  NotificationProvider(super.api);

  /// Populates notifications into our base notification provider
  Future<List<Notification>> _populateNotifications() async {
    await populateAndSetIfChanged(
      api.notificationControllerGetNotifications,
      _notifications,
      (newValue) => _notifications = newValue ?? [],
    );
    notifyListeners();
    return _notifications;
  }

  @override
  Future<void> postLogin() async {
    // Update the firebase config
    await FirebaseNotificationProvider.configure(api);
    await _populateNotifications();
  }

  @override
  Future<void> onSSE(SSEData data) async {
    await super.onSSE(data);
    if (data.event == SSEDataEventEnum.notification) {
      final msg = NotificationSSEDTO.fromJson(data.payload);
      final existingIds = _notifications.map((n) => n.id).toSet();
      await _populateNotifications();

      if (msg != null && msg.popupLatest) {
        final notification = _notifications.firstWhere(
          (n) => !existingIds.contains(n.id),
          orElse: () => _notifications.first,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) => showInAppNotification(notification));
      }
    }
  }

  /// Clears all open overlay notifications
  void clearAllOverlays() {
    for (final entry in _displayedNotifications) {
      if (entry.mounted) entry.remove();
    }
    _displayedNotifications.clear();
  }

  /// Renders an in app notification for when we receive data in the corner of the screen
  void showInAppNotification(Notification notification, {int autoCloseTimeout = 5}) {
    final context = SproutNavigator.key.currentState;
    if (context != null) {
      final overlay = context.overlay;

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) {
          final theme = SproutNavigator.key.currentContext != null
              ? Theme.of(SproutNavigator.key.currentContext!)
              : ThemeData.dark();

          return SproutLayoutBuilder((isDesktop, context, constraints) {
            return SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    type: MaterialType.card,
                    elevation: 8,
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: Dismissible(
                      key: Key('overlay_${notification.id}'),
                      direction: DismissDirection.horizontal,
                      onDismissed: (_) async {
                        // Mark this as read
                        await api.notificationControllerMarkRead(notification.id);
                        // Remove it
                        entry.remove();
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 120, maxWidth: isDesktop ? 520 : 340),
                        child: NotificationItem(notification),
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      );
      // Insert the overlay
      overlay!.insert(entry);
      _displayedNotifications.add(entry);
      // Cleanup the overlay after some time passes
      Future.delayed(Duration(seconds: autoCloseTimeout), () {
        if (entry.mounted) {
          entry.remove();
          _displayedNotifications.remove(entry);
        }
      });
    }
  }
}
