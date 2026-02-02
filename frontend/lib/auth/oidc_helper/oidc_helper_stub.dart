/// The "stub" implementation.
/// This file is used by the compiler to check types, but it is swapped out
/// at runtime for the _web.dart or _io.dart versions.
class OIDCHelper {
  /// Helper to start the authentication flow.
  Future<Map<String, String>?> authenticate() {
    throw UnimplementedError('authenticate() has not been implemented.');
  }
}
