import 'package:sprout/core/api/base.dart';
import 'package:sprout/user/model/user.config.dart';

/// API for user handling
class UserAPI extends BaseAPI {
  UserAPI(super.client);

  /// Returns the current users config
  Future<UserConfig> getUserConfig() async {
    final endpoint = "/user/config";
    dynamic result = await client.get(endpoint);
    return UserConfig.fromJson(result);
  }

  /// Updates the user config in the db and returns it
  Future<UserConfig> updateUserConfig(UserConfig config) async {
    final endpoint = "/user/config/update";
    final body = config.toJson();
    dynamic result = await client.post(body, endpoint);
    return UserConfig.fromJson(result);
  }
}
