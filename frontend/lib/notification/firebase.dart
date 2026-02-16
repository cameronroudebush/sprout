import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/client/extended_api_client.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:sprout/notification/model/firebase_notification_extension.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/user/user_provider.dart';

/// This provider helps us handle firebase connection for push notifications, assuming the API has provided us a firebase config.
class FirebaseNotificationProvider {
  /// Clears all active notifications from the system tray.
  static Future<void> clearNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// When a specific notification is clicked via the app menu, this will be called to tell the backend
  ///   the user saw that notification.
  static void _onNotificationTap(NotificationResponse details) async {
    final notificationId = details.payload;
    if (notificationId != null && notificationId != "") {
      try {
        final notificationProvider = ServiceLocator.get<NotificationProvider>();
        notificationProvider.api.notificationControllerMarkRead(notificationId);
        // Clear the notification from display
        notificationProvider.clearOverlay(notificationId);
      } catch (e) {
        LoggerService.error("Error handling notification tap: $e");
      }
    }
  }

  /// Checks the launch notification when the app resumes/starts up so we know what to do with them
  static void checkLaunchNotification() async {
    if (kIsWeb) return;
    final plugin = FlutterLocalNotificationsPlugin();
    final NotificationAppLaunchDetails? details = await plugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp && details.notificationResponse?.payload != null) {
      FirebaseNotificationProvider._onNotificationTap(details.notificationResponse!);
    }
    await FirebaseNotificationProvider.clearNotifications();
  }

  /// Initializes firebase for our app. We have to wait after login so we can grab the configuration from the backend, encrypted, that contains the firebase tokens
  static Future<void> configure(NotificationApi? api) async {
    if (kIsWeb) return; // Don't even bother with firebase on web
    /// Key used to store firebase config received from the backend.
    const firebaseConfigKey = 'firebase_config';
    FirebaseConfigDTO? config;

    final storageConfig = await SecureStorageProvider.getValue(firebaseConfigKey);
    if (storageConfig != null && storageConfig.isNotEmpty) {
      config = FirebaseConfigDTO.fromJson(jsonDecode(storageConfig));
    }

    // If config is still empty, request it, if capable.
    if (config == null && api != null) {
      final authProvider = ServiceLocator.get<AuthProvider>();
      if (authProvider.currentUser != null) config = await api.notificationControllerGetFirebaseConfig();
    }

    if (config != null) {
      // Save firebase content
      await SecureStorageProvider.saveValue(firebaseConfigKey, jsonEncode(config.toJson()));

      // Skip if we've already initialized
      if (Firebase.apps.isNotEmpty) {
        return;
      }

      final options = FirebaseOptions(
        apiKey: config.apiKey,
        appId: config.appId,
        messagingSenderId: config.projectNumber,
        projectId: config.projectId,
      );

      try {
        await Firebase.initializeApp(options: options);
        await _setupPushNotifications();
      } catch (e) {
        LoggerService.error(e);
      }
    } else {
      LoggerService.warning("No config given for firebase. Ignoring startup.");
    }
  }

  /// Sets up the push notifications to control what to do when we get messages from firebase.
  static Future<void> _setupPushNotifications() async {
    // Request permissions for push notifications
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Make sure the user wants these notifications
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      LoggerService.error("The user did not approve notification permissions. All notifications are disabled.");
      return;
    }

    // Register Background Handler so if the app closes, we can still acquire notifications
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      LoggerService.error("Failed to initialize background firebase messaging $e");
    }

    // Foreground notifications are handled by SSE in notification_provider
  }
}

// Tracks if the background isolate is alive
bool _isIsolateInitialized = false;
// Global instance for the background isolate to reuse
final FlutterLocalNotificationsPlugin _backgroundLocalNotifications = FlutterLocalNotificationsPlugin();

/// Handles what to do with firebase messages in the background.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Since we're in a separate thread, configure firebase without the API.
  try {
    if (!_isIsolateInitialized) {
      await FirebaseNotificationProvider.configure(null);
      // Configure us an API
      await applyDefaultAPI();
      // Configure the necessary providers
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      ServiceLocator.register(ConfigProvider(ConfigApi(), packageInfo));
      final authProvider = ServiceLocator.register(AuthProvider(AuthApi()));
      ServiceLocator.register(UserProvider(UserApi()));
      ServiceLocator.register(NotificationProvider(NotificationApi()));
      // Try to load the auth credentials from the store
      await authProvider.applyDefaultAuth();

      // Initialize local notification settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('ic_notification');
      const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
      await _backgroundLocalNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: FirebaseNotificationProvider._onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: FirebaseNotificationProvider._onNotificationTap,
      );

      _isIsolateInitialized = true;
    }

    // Grab and providers we need
    final notificationProvider = ServiceLocator.get<NotificationProvider>();

    // Fetch the data and show a notification based on that data
    try {
      // Determine the configuration for the notification we need to pull from the backend
      final payload = FirebaseNotificationDTO.fromJson(message.data)!;
      // Grab the notification from the backend. This may fail if the access token is expired.
      final notification = await notificationProvider.api.notificationControllerGetById(payload.notificationId);
      if (notification == null) throw "Failed to find notification";
      String title = notification.title;
      String body = notification.message;

      // Show our notification using the background notifications
      await _backgroundLocalNotifications.show(
        id: DateTime.now().millisecond,
        title: title,
        body: body,
        payload: payload.notificationId,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'secure_channel_${payload.importanceTyped.toString()}',
            'Secure Notifications',
            importance: payload.importanceTyped,
            // largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_notification_large'),
            color: const Color(0xFF141a1f),
          ),
        ),
      );
    } catch (e) {
      LoggerService.error("Failed to process background notification $e");
    }
  } catch (e) {
    LoggerService.error("Failed to initialize background firebase handler $e");
  }
}
