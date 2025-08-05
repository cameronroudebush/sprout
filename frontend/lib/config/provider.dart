import 'package:package_info_plus/package_info_plus.dart';
import 'package:sprout/config/api.dart';
import 'package:sprout/core/api/client.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/model/config.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConfigProvider extends BaseProvider<ConfigAPI> {
  /// The unsecured version of the config that only contains basic information
  UnsecureAppConfiguration? _unsecureConfig;

  /// This is tracked if we fail to get the [_unsecureConfig] or not.
  bool _failedToConnect = false;

  /// The secured config
  Configuration? _config;

  /// Provides the package info for the flutter app including things like versions
  final PackageInfo _packageInfo;

  /// The base URL we're connecting to the backend on
  final String _baseURL = RESTClient.getBaseURL();

  // Public Getters
  Configuration? get config => _config;
  UnsecureAppConfiguration? get unsecureConfig => _unsecureConfig;
  PackageInfo get packageInfo => _packageInfo;
  String get baseUrl => _baseURL;
  bool get failedToConnect => _failedToConnect;

  // Constructor to check initial login status
  ConfigProvider(super.api, this._packageInfo);

  /// Requests the config from the backend and populates [_config]
  Future<Configuration?> populateConfig() async {
    _config = await api.getConfig();
    notifyListeners();
    return _config;
  }

  /// Requests the unsecure config from the backend and populates [_unsecureConfig]
  Future<UnsecureAppConfiguration?> populateUnsecureConfig() async {
    try {
      _unsecureConfig = await api.getUnsecure();
    } catch (e) {
      _failedToConnect = true;
    }
    notifyListeners();
    return unsecureConfig;
  }

  @override
  Future<void> onInit() async {
    populateUnsecureConfig();
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateConfig();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _config = null;
    notifyListeners();
  }

  /// Returns the status of the last account sync
  String getLastSyncStatus() {
    return config?.lastSchedulerRun.time != null ? timeago.format(config!.lastSchedulerRun.time!.toLocal()) : "N/A";
  }
}
