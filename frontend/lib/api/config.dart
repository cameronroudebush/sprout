import 'package:sprout/api/client.dart';

/// Class that provides callable endpoints for the configuration
class ConfigAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  ConfigAPI(this.client);

  /// Get's the unsecure config from the backend. This is data that isn't decremental to security.
  Future<Object> getUnsecure() async {
    final endpoint = "/conf/get/unsecure";
    dynamic result = await this.client.get(endpoint);
    return result;
  }
}
