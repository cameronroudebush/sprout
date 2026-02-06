import 'dart:convert';

import 'package:flutter/material.dart' hide Notification;
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/notification/firebase.dart';
import 'package:sprout/notification/widgets/notification_item.dart';
import 'package:uuid/uuid.dart';

/// Class that provides the store of current net worth information
class NotificationProvider extends BaseProvider<NotificationApi> {
  List<Notification> _notifications = [];
  final Map<String, OverlayEntry> _displayedNotifications = {};

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

        WidgetsBinding.instance.addPostFrameCallback((_) => _showInAppNotification(notification));
      }
    }
  }

  /// Clears a specific notification overlay if it's displayed
  void clearOverlay(String id) {
    if (_displayedNotifications.containsKey(id)) {
      final entry = _displayedNotifications[id];
      if (entry != null && entry.mounted) entry.remove();
      _displayedNotifications.remove(id);
    }
  }

  /// Clears all open overlay notifications
  void clearAllOverlays() {
    for (final entry in _displayedNotifications.values) {
      if (entry.mounted) entry.remove();
    }
    _displayedNotifications.clear();
  }

  /// Renders an in app notification for when we receive data in the corner of the screen
  void _showInAppNotification(
    Notification notification, {
    int autoCloseTimeout = 5,
    bool showDate = true,
    bool showUnreadIndicator = true,
    bool showSpinner = false,
  }) {
    // Clear any existing overlays so we only ever show one
    clearAllOverlays();
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
                        child: NotificationItem(
                          notification,
                          showDate: showDate,
                          showUnreadIndicator: showUnreadIndicator,
                          showSpinner: showSpinner,
                        ),
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
      _displayedNotifications[notification.id] = entry;
      // Cleanup the overlay after some time passes
      Future.delayed(Duration(seconds: autoCloseTimeout), () {
        if (entry.mounted) {
          entry.remove();
          _displayedNotifications.remove(entry);
        }
      });
    }
  }

  /// Opens a notification that is intended to only appear within the app, not saved from the database
  String openFrontendOnly(
    String title, {
    NotificationTypeEnum type = NotificationTypeEnum.info,
    String message = "",
    bool showSpinner = false,
    int duration = 2,
  }) {
    final notification = Notification(
      id: Uuid().v4(),
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
    );
    _showInAppNotification(
      notification,
      autoCloseTimeout: duration,
      showDate: false,
      showUnreadIndicator: false,
      showSpinner: showSpinner,
    );
    return notification.id;
  }

  /// Given an error, attempts to determine a error message
  ///   from it if it's an openAPI exception by parsing the JSON. If it's
  ///   not, it just toString's the error and returns it.
  String parseOpenAPIException(dynamic e) {
    String message;
    if (e is ApiException && e.message != null) {
      try {
        final decoded = json.decode(e.message!);
        message = decoded['message'] ?? e.message;
      } catch (_) {
        message = e.message!;
      }
    } else {
      message = e.toString();
    }
    return message;
  }

  /// Opens an error display for only the frontend with an API exception if decoded. Returns the notification ID that was opened.
  String openWithAPIException(dynamic e) {
    final message = parseOpenAPIException(e);
    return openFrontendOnly(message);
  }
}
