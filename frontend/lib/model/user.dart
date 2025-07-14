class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String username;
  final bool admin;

  String get prettyName {
    if (firstName == null && lastName == null) return username;
    return '$firstName $lastName';
  }

  User({
    required this.id,
    required this.username,
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
    );
  }
}
