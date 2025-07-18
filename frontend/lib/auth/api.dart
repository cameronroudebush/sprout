import 'package:sprout/core/api/base.dart';
import 'package:sprout/model/user.dart';

/// API for backend authentication
class AuthAPI extends BaseAPI {
  // Key used to store the JWT token in secure storage.
  static const String jwtKey = 'jwt_token';

  AuthAPI(super.client);

  /// Authenticates a user with the backend API.
  /// Sends username and password to the login endpoint and stores the received JWT.
  /// [username] The user's username.
  /// [password] The user's password.
  /// Returns true if login is successful and token is stored, false otherwise.
  Future<User?> loginWithPassword(String username, String password) async {
    final endpoint = "/user/login";
    final body = {'username': username, 'password': password};

    dynamic result = await client.post(body, endpoint);
    String? success = result["success"];
    String? jwt = result["jwt"];

    if (jwt != null) {
      await secureStorage.saveValue(jwtKey, jwt);
    }

    if (success == null) {
      return User.fromJson(result["user"]);
    } else {
      return null;
    }
  }

  /// Authenticates a user with the backend API via JWT.
  /// [jwt] The JWT to login with
  /// Returns true if login is successful, false otherwise.
  Future<User?> loginWithJWT(String? jwt) async {
    jwt ??= await secureStorage.getValue(jwtKey);
    final endpoint = "/user/login/jwt";
    final body = {'jwt': jwt};

    if (jwt == null || jwt.isEmpty) {
      return null;
    }

    dynamic result = await client.post(body, endpoint);
    String? success = result["success"];

    // If login fails, clear the jwt
    if (success != null) {
      await secureStorage.saveValue(jwtKey, null);
      return null;
    } else {
      return User.fromJson(result["user"]);
    }
  }

  /// Logs out the current user and wipes the JWT so auto logins are not performed.
  ///   Returns true if the logout was successful, false if not.
  Future<bool> logout() async {
    await secureStorage.saveValue(jwtKey, null);
    return true;
  }
}
