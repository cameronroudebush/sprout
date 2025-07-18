import 'package:sprout/core/api/base.dart';
import 'package:sprout/model/config.dart';

/// Class that provides callable endpoints for the configuration
class ConfigAPI extends BaseAPI {
  ConfigAPI(super.client);

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
