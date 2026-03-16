import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/models/extensions/config_extension.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';

part 'config_provider.g.dart';

/// Future that produces the connection URL of the backend
@Riverpod(keepAlive: true)
Future<String?> connectionUrl(Ref ref) async {
  if (kIsWeb) {
    Uri uri = Uri.base;
    final leading = '${uri.scheme}://${uri.host}';
    return "${kDebugMode ? '$leading:8001' : leading}/api";
  } else {
    String? storedUrl = await SecureStorageProvider.getValue(SecureStorageProvider.connectionUrlKey);
    return (storedUrl == null || storedUrl.isEmpty) ? null : "$storedUrl/api";
  }
}

/// Future that produces the configuration API configured with the base path
/// DOES NOT HAVE AUTHENTICATION
@Riverpod(keepAlive: true)
Future<ConfigApi> configApi(Ref ref) async {
  final client = await ref.watch(baseApiClientProvider.future);
  return ConfigApi(client);
}

/// Future that produces the configuration API configured with the base path and authentication
@Riverpod(keepAlive: true)
Future<ConfigApi> secureConfigApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return ConfigApi(client);
}

/// Extension upon unsecure config that allows state management using riverpod
@Riverpod(keepAlive: true)
class UnsecureConfig extends _$UnsecureConfig {
  bool _failedToConnect = false;
  bool get failedToConnect => _failedToConnect;
  bool get isOIDCAuthMode => state.value?.authMode == UnsecureAppConfigurationAuthModeEnum.oidc;

  @override
  Future<UnsecureAppConfiguration?> build() async {
    try {
      _failedToConnect = false;
      final api = await ref.watch(configApiProvider.future);
      return await api.configControllerGetUnsecure();
    } catch (e) {
      debugPrint("Failed to fetch unsecure config: $e");
      _failedToConnect = true;
      rethrow;
    }
  }

  /// Sets the connection url, persists it, and triggers a full app-wide refresh
  Future<void> setConnectionUrl(String? url) async {
    // Persist the value for future app launches
    await SecureStorageProvider.saveValue(SecureStorageProvider.connectionUrlKey, url);
    // Update the provider that holds the URL.
    ref.invalidate(connectionUrlProvider);
    if (url != null) {
      // Invalidate the API provider so it gets the new basePath from the refreshed connectionUrlProvider
      ref.invalidate(configApiProvider);
      // Finally, invalidate this provider to re-attempt the fetch with the new URL
      ref.invalidateSelf();
    }
    // Await the new state to ensure we handle the result
    await future;
  }

  /// Triggers a retry
  Future<void> retry() async {
    ref.invalidateSelf();
  }
}

/// Extension upon secure config that allows state management using riverpod
@Riverpod(keepAlive: true)
class SecureConfig extends _$SecureConfig {
  @override
  Future<APIConfig?> build() async {
    return populateConfig();
  }

  /// Populates our secured config
  Future<APIConfig?> populateConfig() async {
    final api = await ref.read(secureConfigApiProvider.future);
    final config = await api.configControllerGet();
    state = AsyncData(config);
    return config;
  }

  /// Returns the formatted sync status string from the current state
  String getLastSyncStatus() {
    // Calling the extension property on the state value
    return state.value?.syncStatusString ?? "N/A";
  }

  /// Updates the local state with a new sync status from an SSE event
  void updateLastSync(ModelSync sync) {
    final currentConfig = state.value;
    if (currentConfig != null) {
      // Update the property on the existing object
      currentConfig.lastSchedulerRun = sync;

      // Re-emit the state as AsyncData so all listeners (like the Home Notification) rebuild
      state = AsyncData(currentConfig);
    }
  }
}
