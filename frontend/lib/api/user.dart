import 'package:sprout/api/client.dart';

/// Class that provides callable endpoints for the user
class UserAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  // Key used to store the JWT token in secure storage.
  static const String _jwtKey = 'jwt_token';

  /// Constructor for UserAPI
  UserAPI(this.client);

  /// Authenticates a user with the backend API.
  /// Sends username and password to the login endpoint and stores the received JWT.
  /// [username] The user's username.
  /// [password] The user's password.
  /// Returns true if login is successful and token is stored, false otherwise.
  Future<bool> loginWithPassword(String username, String password) async {
    final endpoint = "/user/login";
    final body = {'username': username, 'password': password};

    try {
      dynamic result = await this.client.post(body, endpoint);
      String? success = result["success"];
      String? jwt = result["jwt"];

      if (jwt != null) {
        this.client.secureStorage.saveValue(_jwtKey, jwt);
      }

      return success == null;
    } catch (e) {
      return false;
    }
  }
}
