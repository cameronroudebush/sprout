import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/firebase_bg_handler.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';

part 'firebase_provider.g.dart';

@Riverpod(keepAlive: true)
class FirebaseNotifier extends _$FirebaseNotifier {
  /// Where we store the firebase config within the secure storage
  static const _firebaseConfigKey = 'firebase_config';
  final _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  void build() {
    return;
  }

  /// Initializes Firebase by fetching encrypted config from the backend.
  ///
  /// This is called post-login to ensure we have the necessary credentials
  /// to register the device for push notifications.
  Future<void> configure([NotificationApi? api]) async {
    if (kIsWeb) return;

    FirebaseConfigDTO? config;
    ;
    final stored = await SecureStorageProvider.getValue(_firebaseConfigKey);

    if (stored != null && stored.isNotEmpty) {
      config = FirebaseConfigDTO.fromJson(jsonDecode(stored));
    }

    // If no stored config and we have an API, try to fetch it
    if (config == null && api != null) {
      config = await api.notificationControllerGetFirebaseConfig();
    }

    if (config != null) {
      // Persist the config for background isolate/offline use
      await SecureStorageProvider.saveValue(_firebaseConfigKey, jsonEncode(config.toJson()));

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: config.apiKey,
            appId: config.appId,
            messagingSenderId: config.projectNumber,
            projectId: config.projectId,
          ),
        );
        await _setupPushNotifications();
      }
    }
  }

  /// Checks if the app was started via a notification and marks it as read.
  /// Also clears the system tray to prevent stale alerts.
  Future<void> checkLaunchNotification() async {
    if (kIsWeb) return;

    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      final response = details.notificationResponse;
      if (response != null) {
        _onNotificationTap(response);
      }
    }
    await clearNotifications();
  }

  /// Requests permissions and registers the background messaging handler.
  Future<void> _setupPushNotifications() async {
    final settings = await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize local settings for tap handling
      const initSettings = InitializationSettings(android: AndroidInitializationSettings('ic_notification'));

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
    }
  }

  /// Handles user interaction when a notification is tapped.
  void _onNotificationTap(NotificationResponse details) async {
    final notificationId = details.payload;
    if (notificationId == null || notificationId.isEmpty) return;

    try {
      final api = await ref.read(notificationApiProvider.future);
      await api.notificationControllerMarkRead(notificationId);

      // Clear specific overlay if app is in foreground
      ref.read(notificationsProvider.notifier).clearOverlay(notificationId);
    } catch (e) {
      LoggerProvider.error("Error handling notification tap: $e");
    }
  }

  /// Clears active notifications from the system tray.
  Future<void> clearNotifications() async {
    await _localNotifications.cancelAll();
  }
}
