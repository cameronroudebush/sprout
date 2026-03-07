import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'config_provider.g.dart';

/// Future that produces the connection URL of the backend
@Riverpod(keepAlive: true)
Future<String> connectionUrl(Ref ref) async {
  if (kIsWeb) {
    Uri uri = Uri.base;
    final leading = '${uri.scheme}://${uri.host}';
    return "${kDebugMode ? '$leading:8001' : leading}/api";
  } else {
    String? storedUrl = await SecureStorageProvider.getValue(SecureStorageProvider.connectionUrlKey);
    return (storedUrl == null || storedUrl.isEmpty) ? "http://localhost/api" : "$storedUrl/api";
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

  /// Returns the last sync status based on the secure config
  String getLastSyncStatus() {
    final config = state.value;
    if (config?.lastSchedulerRun?.time != null) {
      return timeago.format(config!.lastSchedulerRun!.time.toLocal());
    }
    return "N/A";
  }
}
