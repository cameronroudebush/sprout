/// This class defines user configuration options per user
class UserConfig {
  /// If we should hide balances on the users display
  bool privateMode;

  /// The net worth range to display by default
  String netWorthRange;

  UserConfig({this.privateMode = false, this.netWorthRange = "oneDay"});

  Map<String, dynamic> toJson() {
    return {'privateMode': privateMode, 'netWorthRange': netWorthRange};
  }

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(privateMode: json['privateMode'] ?? false, netWorthRange: json['netWorthRange'] ?? "oneDay");
  }
}
