/// This class defines user configuration options per user
class UserConfig {
  /// If we should hide balances on the users display
  bool privateMode;

  UserConfig({this.privateMode = false});

  Map<String, dynamic> toJson() {
    return {'privateMode': privateMode};
  }

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(privateMode: json['privateMode'] ?? false);
  }
}
