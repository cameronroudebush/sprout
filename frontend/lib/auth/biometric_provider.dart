import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/provider_services.dart';

/// A provider intended to only handle biometric authentication for [secureMode]
class BiometricProvider extends BaseProvider with SproutProviders {
  /// Platform for interacting with the activity
  final platform = MethodChannel('security');

  /// Tracks if we're in the middle of an auto logout due to failure in biometric checking
  bool _isLoggingOut = false;

  /// If our devices is locked by biometrics
  bool _isBioLocked = false;

  /// Tracks if we're actively asking to unlock or not
  bool isBioUnlocking = false;

  /// Used for tracking authentication requirements for the app to unlock, besides username/password logins
  final LocalAuthentication _auth = LocalAuthentication();

  /// Public Getters
  bool get isBioLocked => _isBioLocked && authProvider.isLoggedIn;

  BiometricProvider(super.api);

  /// Used during manual logins to reset our locked state
  Future<void> reset() async {
    if (kIsWeb) return;
    _isBioLocked = false;
    _isLoggingOut = false;
    isBioUnlocking = false;
    await disableScreenPrivacy();
    notifyListeners();
  }

  /// Attempts to unlock the biometrics when the app resumes
  Future<void> unlockResume() async {
    if (!kIsWeb && authProvider.isLoggedIn && !_isLoggingOut && isBioLocked && !isBioUnlocking) {
      await _internalUnlock();
      if (!isBioLocked) await disableScreenPrivacy();
    }
  }

  /// When going to the app is going to sleep, locks the app.
  Future<void> lockBackground() async {
    if (!kIsWeb && !isBioUnlocking && !_isLoggingOut && authProvider.isLoggedIn) {
      await _biometricLock();
      await enableScreenPrivacy();
    }
  }

  /// Tries to unlock the biometrics when clicking the unlock button. Returns true if the unlock was a success. False if not.
  Future<bool> tryManualUnlock() async {
    return await _internalUnlock();
  }

  /// Tries to unlock the biometrics used during auto login. Returns true if the unlock was a success. False if not.
  Future<bool> tryAutoLoginUnlock() async {
    return await _internalUnlock(preLogout: true);
  }

  /// Separated to allow us to unlock and auto logout if it fails.
  /// [preLogout] Allows us to customize where to set isBioLocked
  Future<bool> _internalUnlock({bool preLogout = false}) async {
    if (!kIsWeb && userConfigProvider.currentUserConfig!.secureMode) {
      final unlocked = !(await _biometricUnlock());
      if (!unlocked) {
        _isLoggingOut = true;
        if (preLogout) _isBioLocked = false;
        notifyListeners();
        try {
          await authProvider.logout();
        } catch (e) {
          // Ignore logout failure
        }
        _isBioLocked = false;
        _isLoggingOut = false;
        notifyListeners();
        return false;
      }
      return true;
    } else {
      // If we're not required to do biometrics, always return true
      return true;
    }
  }

  /// Locks the app and requires biometrics to access it in the future. Returns if we're locked or not.
  Future<bool> _biometricLock() async {
    if (userConfigProvider.currentUserConfig != null && userConfigProvider.currentUserConfig!.secureMode) {
      _isBioLocked = true;
      notifyListeners();
    }
    return _isBioLocked;
  }

  /// Attempts to unlock the app via biometrics. Returns if we're locked or not.
  Future<bool> _biometricUnlock() async {
    isBioUnlocking = true;
    notifyListeners();
    _isBioLocked = !(await requestBiometricAuth());
    isBioUnlocking = false;
    notifyListeners();
    return _isBioLocked;
  }

  /// Requests a biometric authorization for the app. Used to check if biometrics can be enabled
  Future<bool> requestBiometricAuth() async {
    try {
      // Check if the hardware supports biometrics
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      if (!canAuthenticateWithBiometrics || !isDeviceSupported) return false;
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to view Sprout',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
    }
  }

  /// Disables the screen privacy for FLAG_SECURE
  Future<void> disableScreenPrivacy() async {
    await platform.invokeMethod('disableAppSecurity');
  }

  /// Enables the screen privacy for FLAG_SECURE
  Future<void> enableScreenPrivacy() async {
    await platform.invokeMethod('enableAppSecurity');
  }

  @override
  Future<void> postLogin() async {
    // Enable the screen privacy if needed
    if (!kIsWeb) {
      if (userConfigProvider.currentUserConfig!.secureMode) {
        await enableScreenPrivacy();
      } else {
        await disableScreenPrivacy();
      }
    }
  }
}
