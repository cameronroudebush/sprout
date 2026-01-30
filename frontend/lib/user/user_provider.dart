import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/base.dart';

/// This provide allows for modification to the users via the API including authentication and creating new users.
class UserProvider extends BaseProvider<UserApi> {
  UserProvider(super.api);

  Future<String?> createUser(String username, String password) async {
    final response = await api.userControllerCreate(UserCreationRequest(username: username, password: password));
    return response?.username;
  }

  /// Registers the device of this app with the backend so we can reference it in notifications
  Future<void> registerDevice() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // Don't fire if we don't have a firebase config
    if (Firebase.apps.isEmpty) {
      LoggerService.warning("No firebase configuration is loaded. Refusing to start.");
      return;
    }
    String? token = await FirebaseMessaging.instance.getToken();

    String deviceName = "Unknown Device";
    RegisterDeviceDtoPlatformEnum platform = RegisterDeviceDtoPlatformEnum.android;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.name;
      platform = RegisterDeviceDtoPlatformEnum.ios;
    }

    if (token != null) {
      await api.userControllerRegisterDevice(
        RegisterDeviceDto(token: token, deviceName: deviceName, platform: platform),
      );
    }
  }

  @override
  Future<void> postLogin() async {
    await registerDevice();
  }
}
