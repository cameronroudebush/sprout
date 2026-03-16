import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';
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
  static const _themeCacheKey = 'sprout_theme_style';
  ThemeStyleEnum? _cachedTheme;

  UserConfig? get config => state.value;

  @override
  Future<UserConfig?> build() async {
    // Try to load the theme from cache immediately on startup
    final savedTheme = await SecureStorageProvider.getValue(_themeCacheKey);
    if (savedTheme != null) {
      _cachedTheme = ThemeStyleEnum.values.firstWhere(
        (e) => e.value == savedTheme,
        orElse: () => ThemeStyleEnum.colored,
      );
    }

    // If the user is null, we return null and don't attempt the API call.
    final authState = ref.watch(authProvider);
    if (authState.value == null) return null;

    final config = await populateUserConfig();
    return config;
  }

  /// Returns the theme considering config, cache, then default
  ThemeStyleEnum getTheme(UserConfig? config) {
    return config?.themeStyle ?? _cachedTheme ?? ThemeStyleEnum.colored;
  }

  /// Determines the theme that is in used by the given users config
  ThemeData activeTheme(UserConfig? config) {
    final style = getTheme(config);
    return switch (style) {
      ThemeStyleEnum.bliss => blissLightTheme,
      ThemeStyleEnum.absolute => absoluteDarkTheme,
      ThemeStyleEnum.colored => coloredDarkTheme,
      _ => absoluteDarkTheme,
    };
  }

  /// Updates local cache and persistence
  Future<void> _updateThemeCache(ThemeStyleEnum style) async {
    _cachedTheme = style;
    await SecureStorageProvider.saveValue(_themeCacheKey, style.value);
  }

  Future<UserConfig?> populateUserConfig() async {
    final api = await ref.read(userConfigApiProvider.future);
    final newConfig = await api.userConfigControllerGet();
    if (newConfig != null) await _updateThemeCache(newConfig.themeStyle);
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
      if (result != null) await _updateThemeCache(result.themeStyle);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleSecureMode(bool enable) async {
    final biometricNotifier = ref.read(biometricsProvider.notifier);
    if (enable) {
      final success = await biometricNotifier.requestBiometricAuth();
      if (success) {
        await updateConfig((c) => c.secureMode = true);
        await biometricNotifier.syncNativePrivacy(true);
      }
    } else {
      await updateConfig((c) => c.secureMode = false);
      await biometricNotifier.reset();
      await biometricNotifier.syncNativePrivacy(false);
    }
  }

  /// Updates the apps overall chart range to the given value
  Future<void> updateChartRange(ChartRangeEnum range) async {
    await updateConfig((c) => c.netWorthRange = range);
  }
}
