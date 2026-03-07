import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/api/base_api.dart';

part 'user_config_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UserConfigApi> userConfigApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return UserConfigApi(client);
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

  /// Determines the ThemeMode based on the saved user config
  ThemeMode get themeMode {
    // TODO: Add user setting in the backend
    // final mode = config?.theme?.toLowerCase();
    final mode = "dark";
    return switch (mode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<UserConfig?> populateUserConfig() async {
    final api = await ref.read(userConfigApiProvider.future);
    final newConfig = await api.userConfigControllerGet();
    state = AsyncData(newConfig);
    return newConfig;
  }

  Future<UserConfig?> updateConfig(UserConfig update) async {
    final api = await ref.read(userConfigApiProvider.future);
    final result = await api.userConfigControllerEdit(update);
    ref.invalidateSelf();
    state = AsyncData(result);
    return result;
  }

  Future<void> updateChartRange(ChartRangeEnum range) async {
    final current = state.value;
    if (current != null) {
      current.netWorthRange = range;
      await updateConfig(current);
    }
  }
}
