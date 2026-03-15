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
  @override
  void build() {
    // Listen for authentication changes
    ref.listen(authProvider, (previous, next) {
      print(next.value);
      if (next.value != null && previous?.value == null) {
        registerDevice();
      }
    });
    return;
  }

  /// Registers the device for push notifications.
  Future<void> registerDevice() async {
    if (kIsWeb) return;

    // Check Firebase initialization
    if (Firebase.apps.isEmpty) {
      LoggerProvider.warning("No firebase configuration is loaded. Refusing to start.");
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final deviceInfo = DeviceInfoPlugin();
      String deviceName = "Unknown Device";
      RegisterDeviceDtoPlatformEnum platform = RegisterDeviceDtoPlatformEnum.android;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        platform = RegisterDeviceDtoPlatformEnum.ios;
      }
      final api = await ref.read(userApiProvider.future);
      await api.userControllerRegisterDevice(
        RegisterDeviceDto(token: token, deviceName: deviceName, platform: platform),
      );
    } catch (e) {
      LoggerProvider.error("Failed to register device: $e");
    }
  }
}
