import 'package:sprout/core/api/client.dart';

/// API for user handling
class UserAPI {
  RESTClient client;
  UserAPI(this.client);

  /// Manually runs a sync for new data
  Future<void> runManualSync() async {
    final endpoint = "/sync/manual";
    final body = {};

    await client.post(body, endpoint);
  }
}
