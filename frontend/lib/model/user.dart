import 'package:sprout/user/model/user.config.dart';

class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String username;
  final bool admin;
  final UserConfig config;

  String get prettyName {
    if (firstName == null && lastName == null) return username;
    return '$firstName $lastName';
  }

  User({
    required this.id,
    required this.username,
    required this.config,
    this.firstName,
    this.lastName,
    this.admin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      admin: json['admin'],
      config: UserConfig.fromJson(json['config']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'admin': admin,
      'config': config.toJson(),
    };
  }
}
