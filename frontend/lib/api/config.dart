import 'package:sprout/api/client.dart';
import 'package:sprout/model/config.dart';

/// Class that provides callable endpoints for the configuration
class ConfigAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  ConfigAPI(this.client);

  /// The unsecure config given by the backend for reference
  UnsecureAppConfiguration? unsecureConfig;

  /// Get's the unsecure config from the backend. This is data that isn't decremental to security.
  Future<UnsecureAppConfiguration> getUnsecure() async {
    final endpoint = "/conf/get/unsecure";
    dynamic result = await this.client.get(endpoint);
    return UnsecureAppConfiguration.fromJson(result);
  }

  /// Requests the unsecure config from the backend and populates [unsecureConfig]
  Future<UnsecureAppConfiguration?> populateUnsecureConfig() async {
    this.unsecureConfig = await this.getUnsecure();
    return this.unsecureConfig;
  }
}
