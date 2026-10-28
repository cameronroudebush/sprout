import 'package:sprout/api/api.dart';

/// Helper functions for user
extension UserExtensions on User {
  String get prettyName {
    if (firstName == null && lastName == null) return username;
    return '$firstName $lastName'.trim();
  }

  String get initials {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';

    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    } else if (first.isNotEmpty) {
      return first[0].toUpperCase();
    } else if (last.isNotEmpty) {
      return last[0].toUpperCase();
    } else if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return '';
  }
}
