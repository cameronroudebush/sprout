import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/user/user_config_provider.dart';

part 'biometric_provider.g.dart';

/// Used to track the current biometric state of our app
class BiometricState {
  final bool isLocked;
  final bool isUnlocking;
  final bool isLoggingOut;

  BiometricState({this.isLocked = false, this.isUnlocking = false, this.isLoggingOut = false});

  BiometricState copyWith({bool? isLocked, bool? isUnlocking, bool? isLoggingOut}) {
    return BiometricState(
      isLocked: isLocked ?? this.isLocked,
      isUnlocking: isUnlocking ?? this.isUnlocking,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
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

  // UI helpers
  bool get isLocked => state.isLocked && (ref.read(authProvider).value != null);

  @override
  BiometricState build() {
    // Automatically manage screen privacy when config changes
    ref.listen(userConfigProvider, (prev, next) {
      final config = next.value;
      if (config?.secureMode == true) {
        enableScreenPrivacy();
      } else {
        disableScreenPrivacy();
      }
    });

    return BiometricState();
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
    state = BiometricState(isLocked: false);
    await disableScreenPrivacy();
  }

  /// App Resumed: Cancel timer and try to unlock if needed
  Future<void> unlockResume() async {
    _lockTimer?.cancel();
    _lockTimer = null;

    final secureMode = ref.read(userConfigProvider).value?.secureMode ?? false;
    if (!secureMode) {
      await disableScreenPrivacy();
      return;
    }

    final isLoggedIn = ref.read(authProvider).value != null;
    if (!kIsWeb && isLoggedIn && !state.isLoggingOut && state.isLocked && !state.isUnlocking) {
      await _internalUnlock();
      if (!state.isLocked) await disableScreenPrivacy();
    }
  }

  /// App Background-ed: Start grace period timer
  Future<void> lockBackground() async {
    final isLoggedIn = ref.read(authProvider).value != null;
    if (kIsWeb || state.isUnlocking || state.isLoggingOut || !isLoggedIn) return;

    final secureMode = ref.read(userConfigProvider).value?.secureMode ?? false;
    if (secureMode) {
      await enableScreenPrivacy();
      _lockTimer ??= Timer(_lockGracePeriod, () {
        state = state.copyWith(isLocked: true);
        _lockTimer = null;
      });
    } else {
      await disableScreenPrivacy();
    }
  }

  Future<bool> _internalUnlock({bool preLogout = false}) async {
    final secureMode = ref.read(userConfigProvider).value?.secureMode ?? false;

    if (!kIsWeb && secureMode) {
      final success = await requestBiometricAuth();
      if (!success) {
        state = state.copyWith(isLoggingOut: true, isLocked: preLogout ? false : state.isLocked);
        try {
          await ref.read(authProvider.notifier).logout();
        } finally {
          state = BiometricState(isLocked: false, isLoggingOut: false);
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
      if (!canCheck || !isSupported) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to view Sprout',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
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
}
