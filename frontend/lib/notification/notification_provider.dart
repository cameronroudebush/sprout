import 'dart:convert';

import 'package:flutter/material.dart' hide Notification;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/widgets/notification_item.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:uuid/uuid.dart';

part 'notification_provider.g.dart';

/// Returns the notification api future considering the authenticated client
@Riverpod(keepAlive: true)
Future<NotificationApi> notificationApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return NotificationApi(client);
}

/// Describes the riverpod state for our notifications set
@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  final Map<String, OverlayEntry> _displayedNotifications = {};

  // Ui info
  bool get hasUnread => (state.value ?? []).any((n) => !n.isRead);

  @override
  Future<List<Notification>> build() async {
    final api = await ref.watch(notificationApiProvider.future);

    // 1. Setup Firebase (Replaces postLogin logic)
    // We do this as a side effect of the provider being initialized
    // await FirebaseNotificationProvider.configure(api); // TODO

    // Listen to SSE for new notifications
    ref.listen(sseProvider, (previous, next) async {
      final data = next.value;
      if (data?.event == SSEDataEventEnum.notification) {
        final msg = NotificationSSEDTO.fromJson(data!.payload);

        // Refresh the list
        final oldIds = (state.value ?? []).map((n) => n.id).toSet();
        ref.invalidateSelf();

        // Wait for refresh to complete to find the new one for the popup
        final newList = await future;
        if (msg != null && msg.popupLatest) {
          final notification = newList.firstWhere((n) => !oldIds.contains(n.id), orElse: () => newList.first);
          _showInAppNotification(notification);
        }
      }
    });

    return await api.notificationControllerGetNotifications() ?? [];
  }

  /// Opens a notification with the given info
  void _showInAppNotification(
    Notification notification, {
    int autoCloseTimeout = 5,
    bool showDate = true,
    bool showUnreadIndicator = true,
    bool showSpinner = false,
    bool frontendOnly = false,
  }) {
    clearAllOverlays();
    final navigatorState = NavigationProvider.key.currentState;
    if (navigatorState == null) return;

    final overlay = navigatorState.overlay;
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(navigatorState.context);
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
                      if (!frontendOnly) {
                        final api = await ref.read(notificationApiProvider.future);
                        await api.notificationControllerMarkRead(notification.id);
                      }
                      entry.remove();
                      _displayedNotifications.remove(notification.id);
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

    overlay?.insert(entry);
    _displayedNotifications[notification.id] = entry;

    Future.delayed(Duration(seconds: autoCloseTimeout), () {
      if (entry.mounted) {
        entry.remove();
        _displayedNotifications.remove(notification.id);
      }
    });
  }

  /// Closes all open notifications
  void clearAllOverlays() {
    for (final entry in _displayedNotifications.values) {
      if (entry.mounted) entry.remove();
    }
    _displayedNotifications.clear();
  }

  /// Opens a frontend only notification. These are not tracked in the backend
  String openFrontendOnly(
    String title, {
    NotificationTypeEnum type = NotificationTypeEnum.info,
    String message = "",
    bool showSpinner = false,
    int duration = 2,
  }) {
    final notification = Notification(
      id: const Uuid().v4(),
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
      frontendOnly: true,
    );
    return notification.id;
  }

  /// Parses an OpenAPI exception and attempts to extract the message out of it assuming it's JSON
  String parseOpenAPIException(dynamic e) {
    if (e is ApiException && e.message != null) {
      try {
        final decoded = json.decode(e.message!);
        return decoded['message'] ?? e.message;
      } catch (_) {
        return e.message!;
      }
    }
    return e.toString();
  }

  /// Opens a frontend only notification with the OpenAPI exception info
  String openWithAPIException(dynamic e) {
    return openFrontendOnly(parseOpenAPIException(e));
  }
}
