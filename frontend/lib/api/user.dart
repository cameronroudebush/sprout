import 'package:sprout/api/client.dart';
import 'package:sprout/model/user.dart';

/// Class that provides callable endpoints for the user
class UserAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  // Key used to store the JWT token in secure storage.
  static const String jwtKey = 'jwt_token';

  /// Constructor for UserAPI
  UserAPI(this.client);

  /// Returns the current JWT as saved in storage
  Future<String?> getJWT() async {
    return await client.secureStorage.getValue(jwtKey);
  }

  /// Authenticates a user with the backend API.
  /// Sends username and password to the login endpoint and stores the received JWT.
  /// [username] The user's username.
  /// [password] The user's password.
  /// Returns true if login is successful and token is stored, false otherwise.
  Future<User?> loginWithPassword(String username, String password) async {
    final endpoint = "/user/login";
    final body = {'username': username, 'password': password};

    try {
      dynamic result = await this.client.post(body, endpoint);
      String? success = result["success"];
      String? jwt = result["jwt"];

      if (jwt != null) {
        await this.client.secureStorage.saveValue(jwtKey, jwt);
      }

      if (success == null) {
        return User.fromJson(result["user"]);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Authenticates a user with the backend API via JWT.
  /// [jwt] The JWT to login with
  /// Returns true if login is successful, false otherwise.
  Future<User?> loginWithJWT(String? jwt) async {
    jwt ??= await getJWT();
    final endpoint = "/user/login/jwt";
    final body = {'jwt': jwt};

    if (jwt == null || jwt.isEmpty) {
      return null;
    }

    try {
      dynamic result = await client.post(body, endpoint);
      String? success = result["success"];

      // If login fails, clear the jwt
      if (success != null) {
        await client.secureStorage.saveValue(jwtKey, null);
        return null;
      } else {
        return User.fromJson(result["user"]);
      }
    } catch (e) {
      return null;
    }
  }

  /// Logs out the current user and wipes the JWT so auto logins are not performed.
  ///   Returns true if the logout was successful, false if not.
  Future<bool> logout() async {
    await client.secureStorage.saveValue(jwtKey, null);
    return true;
  }
}
