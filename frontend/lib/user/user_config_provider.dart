import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/theme/absolute_dark.dart';
import 'package:sprout/theme/bliss_light.dart';
import 'package:sprout/theme/colored_dark.dart';

part 'user_config_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UserConfigApi> userConfigApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return UserConfigApi(client);
}

@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) async {
  return await PackageInfo.fromPlatform();
}

@Riverpod(keepAlive: true)
class UserConfigNotifier extends _$UserConfigNotifier {
  /// Getters for UI
  UserConfig? get config => state.value;

  @override
  Future<UserConfig?> build() async {
    // If the user is null, we return null and don't attempt the API call.
    final authState = ref.watch(authProvider);

    if (authState.value == null) {
      return null;
    }

    return await populateUserConfig();
  }

  /// Determines the dark theme to use based on the user config
  ThemeData get activeTheme {
    // TODO: Add user setting in the backend
    final style = "colored";

    return switch (style) {
      'bliss' => blissLightTheme,
      'absolute' => absoluteDarkTheme,
      'colored' => coloredDarkTheme,
      _ => absoluteDarkTheme,
    };
  }

  Future<UserConfig?> populateUserConfig() async {
    final api = await ref.read(userConfigApiProvider.future);
    final newConfig = await api.userConfigControllerGet();
    state = AsyncData(newConfig);
    return newConfig;
  }

  /// Safely update the config using a callback for full type-safety.
  /// Usage: ref.read(userConfigProvider.notifier).update((c) => c.privateMode = true);
  Future<void> updateConfig(void Function(UserConfig) callback) async {
    final current = state.value;
    if (current == null) return;
    callback(current);
    await _sendUpdate(current);
  }

  /// Internal helper to push to API and update local state
  Future<void> _sendUpdate(UserConfig updatedConfig) async {
    state = const AsyncLoading();
    try {
      final api = await ref.read(userConfigApiProvider.future);
      final result = await api.userConfigControllerEdit(updatedConfig);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleSecureMode(bool enable) async {
    final provider = ref.read(biometricsProvider.notifier);
    if (enable) {
      final success = await provider.requestBiometricAuth();
      if (success) {
        await updateConfig((c) => c.secureMode = true);
      }
    } else {
      await updateConfig((c) => c.secureMode = false);
      await provider.reset();
    }
  }

  /// Updates the apps overall chart range to the given value
  Future<void> updateChartRange(ChartRangeEnum range) async {
    await updateConfig((c) => c.netWorthRange = range);
  }
}
