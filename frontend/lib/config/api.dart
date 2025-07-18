import 'package:package_info_plus/package_info_plus.dart';
import 'package:sprout/core/api/client.dart';
import 'package:sprout/model/config.dart';

/// Class that provides callable endpoints for the configuration
class ConfigAPI {
  /// The base URL we're connecting to the backend on
  final String baseURL;
  final PackageInfo packageInfo;
  UnsecureAppConfiguration? unsecureConfig;
  RESTClient client;
  ConfigAPI(this.client, this.packageInfo, this.baseURL);

  /// Requests the unsecure config from the backend and populates [unsecureConfig]
  Future<UnsecureAppConfiguration?> populateUnsecureConfig() async {
    unsecureConfig = await getUnsecure();
    return unsecureConfig;
  }

  /// Get's the unsecure config from the backend. This is data that isn't decremental to security.
  Future<UnsecureAppConfiguration> getUnsecure() async {
    final endpoint = "/conf/get/unsecure";
    dynamic result = await this.client.get(endpoint);
    return UnsecureAppConfiguration.fromJson(result);
  }

  Future<Configuration> getConfig() async {
    final endpoint = "/conf/get";
    dynamic result = await this.client.get(endpoint);
    return Configuration.fromJson(result);
  }
}
