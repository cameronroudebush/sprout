import 'package:sprout/api/api.dart';

/// Helper functions for user
extension UserExtensions on User {
  String get prettyName {
    if (firstName == null && lastName == null) return username;
    return '$firstName $lastName';
  }
}
