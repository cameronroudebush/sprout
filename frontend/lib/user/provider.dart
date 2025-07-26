import 'package:sprout/core/provider/base.dart';
import 'package:sprout/user/api.dart';
import 'package:sprout/user/model/user.config.dart';

/// Class that provides user information
class UserProvider extends BaseProvider<UserAPI> {
  UserConfig? _currentUserConfig;

  UserConfig? get currentUserConfig => _currentUserConfig;

  UserProvider(super.api);

  Future<UserConfig> updateConfig(config) async {
    _currentUserConfig = await api.updateUserConfig(config);
    notifyListeners();
    return _currentUserConfig!;
  }

  Future<UserConfig?> populateUserConfig() async {
    _currentUserConfig = await api.getUserConfig();
    notifyListeners();
    return _currentUserConfig;
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateUserConfig();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _currentUserConfig = null;
    notifyListeners();
  }
}
