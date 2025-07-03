import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A class that provides secure storage for properties
class SecureStorage {
  // Secure storage instance for storing the JWT token.
  final _storage = const FlutterSecureStorage();

  /// Saves the given value to the given key
  Future<void> saveValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Given a key of a value, returns it from the secure storage
  Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }
}
