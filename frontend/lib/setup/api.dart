import 'package:sprout/core/api/client.dart';

/// Class that provides endpoints to call for initial setup of the app
class SetupAPI {
  /// Base URL of the sprout backend API
  RESTClient client;
  SetupAPI(this.client);

  /// Creates the initial user for the setup page
  /// [username] The username to use
  /// [password] The password to use
  Future<bool> createUser(String username, String password) async {
    final endpoint = "/setup/user";
    final body = {'username': username, 'password': password};
    try {
      await this.client.post(body, endpoint);
      return true;
    } catch (e) {
      return false;
    }
  }
}
