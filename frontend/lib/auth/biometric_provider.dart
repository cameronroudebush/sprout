import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/user/user_config_provider.dart';

part 'biometric_provider.g.dart';

/// Used to track the current biometric state of our app
class BiometricState {
  final bool isLocked;
  final bool isUnlocking;
  final bool isLoggingOut;
  final bool hasInitialized;

  BiometricState({
    this.isLocked = false,
    this.isUnlocking = false,
    this.isLoggingOut = false,
    this.hasInitialized = false,
  });

  BiometricState copyWith({bool? isLocked, bool? isUnlocking, bool? isLoggingOut, bool? hasInitialized}) {
    return BiometricState(
      isLocked: isLocked ?? this.isLocked,
      isUnlocking: isUnlocking ?? this.isUnlocking,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      hasInitialized: hasInitialized ?? this.hasInitialized,
    );
  }
}

/// A provider that tracks our current biometric lock/unlock state and how to do the loc/unlock
@Riverpod(keepAlive: true)
class Biometrics extends _$Biometrics {
  final _platform = const MethodChannel("net.croudebush.sprout/security");
  final _auth = LocalAuthentication();
  final _lockGracePeriod = const Duration(minutes: 5);
  Timer? _lockTimer;

  @override
  BiometricState build() {
    return BiometricState(isLocked: false, hasInitialized: false);
  }

  /// Checks the lock state using the user config if we should lock the app or not
  Future<void> checkLockState(UserConfig conf) async {
    final isManualLogin = ref.read(sessionStatusProvider);
    if (!kIsWeb && conf.secureMode && !isManualLogin) {
      state = state.copyWith(isLocked: true, hasInitialized: true);
      await tryManualUnlock();
    } else {
      state = state.copyWith(hasInitialized: true);
    }
  }

  /// Explicitly sync native privacy state with config
  /// This should be called after a successful login or when security settings change
  Future<void> _syncNativePrivacy(bool secureMode) async {
    if (kIsWeb) return;
    if (secureMode) {
      await enableScreenPrivacy();
    } else {
      await disableScreenPrivacy();
    }
  }

  /// Tries to unlock the biometrics when clicking the unlock button. Returns true if the unlock was a success. False if not.
  Future<bool> tryManualUnlock() async {
    return await _internalUnlock();
  }

  /// Resets our biometric lock state to disable it
  Future<void> reset() async {
    if (kIsWeb) return;
    _lockTimer?.cancel();
    _lockTimer = null;
    state = BiometricState(isLocked: false, hasInitialized: true);
    await disableScreenPrivacy();
  }

  /// App Resumed: Cancel timer and try to unlock if needed
  Future<void> unlockResume({VoidCallback? onResume}) async {
    _lockTimer?.cancel();
    _lockTimer = null;

    final secureMode = ref.read(userConfigProvider).value?.secureMode ?? false;
    if (!secureMode) {
      await disableScreenPrivacy();
      return;
    }

    final isLoggedIn = ref.read(authProvider).value != null;
    if (!kIsWeb && isLoggedIn && !state.isLoggingOut && state.isLocked && !state.isUnlocking) {
      final success = await _internalUnlock();
      if (success) {
        if (!state.isLocked) await disableScreenPrivacy();
        onResume?.call();
      }
    }
  }

  /// App Background-ed: Start grace period timer
  Future<void> lockBackground() async {
    final isLoggedIn = ref.read(authProvider).value != null;
    if (kIsWeb || state.isUnlocking || state.isLoggingOut || !isLoggedIn) return;

    final secureMode = ref.read(userConfigProvider).value?.secureMode ?? false;
    if (secureMode) {
      ref.read(sessionStatusProvider.notifier).state = false;
      await enableScreenPrivacy();
      _lockTimer = Timer(_lockGracePeriod, () {
        if (ref.mounted) {
          state = state.copyWith(isLocked: true);
          LoggerProvider.debug("Grace period expired. Sprout is now locked.");
        }
        _lockTimer = null;
      });
    } else {
      await disableScreenPrivacy();
    }
  }

  /// Returns a bool if the biometric authentication was successful
  Future<bool> _internalUnlock({bool preLogout = false}) async {
    final secureMode = ref.read(userConfigProvider).value?.secureMode ?? false;
    state = state.copyWith(hasInitialized: true);

    if (!kIsWeb && secureMode) {
      final success = await requestBiometricAuth();
      if (!success) {
        state = state.copyWith(isLoggingOut: true, isLocked: preLogout ? false : state.isLocked);
        try {
          await ref.read(authProvider.notifier).logout();
        } finally {
          state = BiometricState(isLocked: false, isLoggingOut: false, hasInitialized: true);
        }
        return false;
      }
      state = state.copyWith(isLocked: false);
      return true;
    }
    return true;
  }

  /// Request that the user verifies they can use biometrics
  Future<bool> requestBiometricAuth() async {
    state = state.copyWith(isUnlocking: true);
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        throw "Biometrics are not supported or enabled on this device.";
      }

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to view Sprout',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.userCanceled) {
        throw "User canceled enrollment";
      }
      throw "An unexpected error occurred";
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isUnlocking: false);
    }
  }

  /// Disables the background screen privacy blackout
  Future<void> disableScreenPrivacy() async {
    if (!kIsWeb) await _platform.invokeMethod('disableAppSecurity');
  }

  // Enables the background screen privacy lockout
  Future<void> enableScreenPrivacy() async {
    final secureMode = ref.read(userConfigProvider).value?.secureMode ?? false;
    if (!kIsWeb && secureMode) {
      await _platform.invokeMethod('enableAppSecurity');
    }
  }

  /// Toggles the current secure mode if we should consider biometric auth or not
  Future<void> toggleSecureMode(bool enable) async {
    if (enable) {
      final success = await requestBiometricAuth();
      if (success) {
        await ref.read(userConfigProvider.notifier).updateConfig((c) => c.secureMode = true);
        await _syncNativePrivacy(true);
      }
    } else {
      await ref.read(userConfigProvider.notifier).updateConfig((c) => c.secureMode = false);
      await reset();
      await _syncNativePrivacy(false);
    }
  }
}
