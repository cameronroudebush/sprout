import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';
import 'package:sprout/theme/absolute_dark.dart';
import 'package:sprout/theme/bliss_light.dart';
import 'package:sprout/theme/colored_dark.dart';
import 'package:sprout/user/models/extensions/use_config_extensions.dart';

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

    // Only watch for user ID changes
    final userId = ref.watch(authProvider.select((s) => s.value?.id));
    if (userId == null) return null;

    final config = await populateUserConfig();
    // Populate biometrics consideration
    try {
      await ref.read(biometricsProvider.notifier).checkLockState(config!);
    } catch (e) {
      /// Ignore errors, we'll allow them to re-auth via the lock screen
    }

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
  /// Usage: ref.read(userConfigProvider.notifier).update((c) => c.copyWith(privateMode: true));
  Future<void> updateConfig(UserConfig Function(UserConfig) callback) async {
    final current = state.value;
    if (current == null) return;
    final updatedClone = callback(current);
    final success = await _sendUpdate(updatedClone);
    if (success) {
      state = AsyncValue.data(updatedClone);
    }
  }

  /// Internal helper to push to API and update local state
  /// Returns true for success
  Future<bool> _sendUpdate(UserConfig updatedConfig) async {
    final previousState = state;
    try {
      final api = await ref.read(userConfigApiProvider.future);
      final result = await api.userConfigControllerEdit(updatedConfig);
      if (result != null) await _updateThemeCache(result.themeStyle);
      state = AsyncData(result);
      return true;
    } catch (e) {
      ref.read(notificationsProvider.notifier).openWithAPIException(e);
      state = previousState;
      return false;
    }
  }

  /// Updates the apps overall chart range to the given value
  Future<void> updateChartRange(ChartRangeEnum range) async {
    await updateConfig((c) => c.copyWith(netWorthRange: range));
  }
}
