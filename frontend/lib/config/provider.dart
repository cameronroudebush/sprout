import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/config/api.dart';
import 'package:sprout/model/config.dart';

class ConfigProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final ConfigAPI _configAPI;

  /// The secured config
  Configuration? _config;

  Configuration get config => _config as Configuration;
  UnsecureAppConfiguration get unsecureConfig => _configAPI.unsecureConfig as UnsecureAppConfiguration;
  PackageInfo get packageInfo => _configAPI.packageInfo;

  // Constructor to check initial login status
  ConfigProvider(this._configAPI, this._authProvider) {
    if (_authProvider != null && _authProvider.isLoggedIn && _config == null) {
      populateConfig();
    }
  }

  Future<Configuration?> populateConfig() async {
    _config = await _configAPI.getConfig();
    return _config;
  }
}
