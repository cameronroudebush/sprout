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

  /// Returns a list of maps, each describing a configurable setting.
  /// This is used to dynamically build the UI.
  List<Map<String, dynamic>> getSettingsList() {
    return [
      {
        'key': 'privateMode',
        'label': 'Hide Account Balances',
        'value': privateMode,
        'type': bool,
        'hint': 'If you would like to hide your account balances, toggle this to true.',
      },
    ];
  }
}
