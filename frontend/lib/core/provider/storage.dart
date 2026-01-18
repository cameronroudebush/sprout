import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A class that provides secure storage for properties
class SecureStorageProvider {
  /// Key used to store the connection url in storage so we know where we're connecting.
  static const String connectionUrlKey = 'connection_url';

  /// Key used to store the access token info from OAUTH.
  static const String accessToken = 'access_token';

  /// Key used to store the JWT that contains the ID for either local or OAUTH strategy.
  static const String idToken = 'id_token';

  // Secure storage instance for storing the JWT token.
  static final _storage = const FlutterSecureStorage();

  /// Saves the given value to the given key
  static Future<void> saveValue(String key, String? value) async {
    await _storage.write(key: key, value: value);
  }

  /// Given a key of a value, returns it from the secure storage
  static Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }
}
