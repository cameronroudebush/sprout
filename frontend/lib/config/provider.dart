import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConfigProvider extends BaseProvider<ConfigApi> {
  /// The URL we are connecting to on the backend including any trailing base path
  static String? connectionUrl;

  /// The unsecured version of the config that only contains basic information
  UnsecureAppConfiguration? _unsecureConfig;

  /// This is tracked if we fail to get the [_unsecureConfig] or not.
  bool _failedToConnect = false;

  /// The secured config
  APIConfig? _config;

  /// Provides the package info for the flutter app including things like versions
  final PackageInfo _packageInfo;

  // Public Getters
  APIConfig? get config => _config;
  UnsecureAppConfiguration? get unsecureConfig => _unsecureConfig;
  PackageInfo get packageInfo => _packageInfo;
  bool get failedToConnect => _failedToConnect;
  bool get isOIDCAuthMode => _unsecureConfig?.authMode == UnsecureAppConfigurationAuthModeEnum.oidc;

  // Constructor to check initial login status
  ConfigProvider(super.api, this._packageInfo);

  /// Requests the config from the backend and populates [_config]
  Future<APIConfig?> populateConfig() async {
    _config = await api.configControllerGet();
    notifyListeners();
    return _config;
  }

  /// Requests the unsecure config from the backend and populates [_unsecureConfig]
  Future<UnsecureAppConfiguration?> populateUnsecureConfig() async {
    try {
      _failedToConnect = false;
      _unsecureConfig = await api.configControllerGetUnsecure();
    } catch (e) {
      LoggerService.error(e, error: e);
      _failedToConnect = true;
      // If this is debug, manually refresh. This is because SSE can tend
      //  to timeout due to dispose not being called on hot reloads.
      // This is a terrible way to patch this. We just need dispose to fire on hot reloads
      // if (kDebugMode && kIsWeb) {
      //   window.location.reload();
      // }
    }
    notifyListeners();
    return unsecureConfig;
  }

  @override
  Future<void> onInit() async {
    await populateUnsecureConfig();
    await super.onInit();
  }

  @override
  Future<void> postLogin() async {
    await populateConfig();
  }

  @override
  Future<void> cleanupData() async {
    _config = null;
    notifyListeners();
  }

  /// Returns the status of the last account sync
  String getLastSyncStatus() {
    return config?.lastSchedulerRun?.time != null ? timeago.format(config!.lastSchedulerRun!.time.toLocal()) : "N/A";
  }

  /// Gets what the current connection url should be
  static Future<String> getConnUrl() async {
    if (kIsWeb) {
      // Web can base connections on the uri of the current connection
      Uri uri = Uri.base;
      final leading = '${uri.scheme}://${uri.host}';
      return "${kDebugMode ? '$leading:8001' : leading}/api";
    } else {
      // Apps must specify the connection URL so we know where to look
      String? storedUrl = await SecureStorageProvider.getValue(SecureStorageProvider.connectionUrlKey);
      if (storedUrl == null || storedUrl.isEmpty) storedUrl = "http://localhost";
      return "$storedUrl/api";
    }
  }

  /// Returns if we have a connection URL or not
  bool hasConnectionUrl() {
    return ConfigProvider.connectionUrl != null;
  }
}
