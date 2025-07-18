import 'package:sprout/core/api/base.dart';

/// API for user handling
class UserAPI extends BaseAPI {
  UserAPI(super.client);

  /// Manually runs a sync for new data
  Future<void> runManualSync() async {
    final endpoint = "/sync/manual";
    final body = {};

    await client.post(body, endpoint);
  }
}
