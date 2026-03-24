import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/notification/firebase_provider.dart';
import 'package:sprout/notification/models/extensions/firebase_notification_extension.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:uuid/uuid.dart';

/// Global plugin instance for the background isolate.
final FlutterLocalNotificationsPlugin _bgLocalNotifications = FlutterLocalNotificationsPlugin();

/// Entry point for Firebase messages when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a container to access Sprout providers in the background
  final container = ProviderContainer();
  Notification? notification;
  Importance importance = Importance.defaultImportance;

  try {
    // Re-configure Firebase for this isolate
    await container.read(firebaseProvider.notifier).configure();
    await container.read(authProvider.notifier).applyDefaultAuth();

    // Determine notification payload
    final payload = FirebaseNotificationDTO.fromJson(message.data)!;
    importance = payload.importanceTyped;

    // Attempt to fetch full notification details from backend
    final api = await container.read(notificationApiProvider.future);
    notification = await api.notificationControllerGetById(payload.notificationId);
  } catch (e) {
    LoggerProvider.error(e);
    // Fallback if network fails or token is expired
    notification = Notification(
      id: Uuid().v4(),
      title: "New Activity",
      message: "Sign in to view details.",
      type: NotificationTypeEnum.info,
      createdAt: DateTime.now(),
    );
  }

  // Show the local notification
  await _bgLocalNotifications.show(
    id: DateTime.now().millisecond,
    title: notification!.title,
    body: notification.message,
    payload: notification.id,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        'secure_channel',
        'Secure Notifications',
        importance: importance,
        color: Color(0xFF141A1F),
      ),
    ),
  );
  // Cleanup
  container.dispose();
}
