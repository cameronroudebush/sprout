import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';
import 'package:uuid/uuid.dart';

part 'user_provider.g.dart';

/// Provides the UserApi with the correct base path automatically.
@Riverpod(keepAlive: true)
Future<UserApi> userApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return UserApi(client);
}

/// Manages User-related actions like device registration.
@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  /// Storage key for secure storage on the devices ID
  static const String _deviceIdStorageKey = 'device_unique_id';

  @override
  void build() {
    // Listen for authentication changes
    ref.listen(authProvider, (previous, next) {
      if (next.value != null && previous?.value == null) {
        registerDevice();
      }
    });
    return;
  }

  /// Registers the device for push notifications.
  Future<void> registerDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = "Unknown Device";
    String uniqueHardwareId = "";
    RegisterDeviceDtoPlatformEnum platform = RegisterDeviceDtoPlatformEnum.android;

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        final browserName = webInfo.browserName.name.toUpperCase();
        final os = webInfo.platform ?? "Web";
        deviceName = "$browserName ($os)";
        platform = RegisterDeviceDtoPlatformEnum.web;
        uniqueHardwareId = await _getUniqueDeviceId(web: webInfo);
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
        platform = RegisterDeviceDtoPlatformEnum.android;
        uniqueHardwareId = await _getUniqueDeviceId(android: androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        platform = RegisterDeviceDtoPlatformEnum.ios;
        uniqueHardwareId = await _getUniqueDeviceId(ios: iosInfo);
      }
    } catch (e) {
      LoggerProvider.warning("Failed to resolve device metadata: $e");
    }

    // Fetch FCM Token if Firebase is initialized and web/app permissions are granted
    String? fcmToken;
    if (Firebase.apps.isNotEmpty) {
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        LoggerProvider.warning("FCM token fetch skipped or blocked: $e");
      }
    }

    // Register device with backend
    try {
      final api = await ref.read(userApiProvider.future);
      await api.userControllerRegisterDevice(
        RegisterDeviceDto(
          deviceId: uniqueHardwareId,
          token: fcmToken,
          deviceName: deviceName,
          platform: platform,
        ),
      );
    } catch (e) {
      LoggerProvider.error("Failed to register device: $e");
    }
  }

  /// Returns an ID unique to this user device
  Future<String> _getUniqueDeviceId({
    AndroidDeviceInfo? android,
    IosDeviceInfo? ios,
    WebBrowserInfo? web,
  }) async {
    // Try Hardware/OS ID first
    if (android?.id.isNotEmpty == true) {
      return android!.id;
    }
    if (ios?.identifierForVendor != null) {
      return ios!.identifierForVendor!;
    }

    // Fallback: Persistent local UUID stored on device
    String? storedId = await SecureStorageProvider.getValue(_deviceIdStorageKey);

    if (storedId == null || storedId.isEmpty) {
      storedId = const Uuid().v4();
      await SecureStorageProvider.saveValue(_deviceIdStorageKey, storedId);
    }

    return storedId;
  }
}
