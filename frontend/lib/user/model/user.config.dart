/// This class defines user configuration options per user
class UserConfig {
  /// If we should hide balances on the users display
  bool privateMode;

  /// The net worth range to display by default
  String netWorthRange;

  /// A URL set by the frontend if sprout is running in non web mode
  String? connectionUrl;

  UserConfig({this.privateMode = false, this.netWorthRange = "oneDay", this.connectionUrl});

  Map<String, dynamic> toJson() {
    return {'privateMode': privateMode, 'netWorthRange': netWorthRange};
  }

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(privateMode: json['privateMode'] ?? false, netWorthRange: json['netWorthRange'] ?? "oneDay");
  }
}
