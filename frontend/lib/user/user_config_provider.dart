import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides user configuration information
class UserConfigProvider extends BaseProvider<UserConfigApi> {
  UserConfig? _currentUserConfig;

  UserConfig? get currentUserConfig => _currentUserConfig;
  ChartRangeEnum get userDefaultChartRange => _currentUserConfig?.netWorthRange ?? ChartRangeEnum.oneDay;

  UserConfigProvider(super.api);

  Future<UserConfig?> updateConfig(config) async {
    _currentUserConfig = await api.userConfigControllerEdit(config);
    notifyListeners();
    return _currentUserConfig;
  }

  Future<UserConfig?> populateUserConfig() async {
    _currentUserConfig = await api.userConfigControllerGet();
    notifyListeners();
    return _currentUserConfig;
  }

  /// Updates the users last selected chart range to the given value
  Future<void> updateChartRange(ChartRangeEnum range) async {
    currentUserConfig!.netWorthRange = range;
    updateConfig(currentUserConfig!);
  }

  @override
  Future<void> postLogin() async {
    setLoadingStatus(true);
    await populateUserConfig();
    setLoadingStatus(false);
  }

  @override
  Future<void> cleanupData() async {
    _currentUserConfig = null;
    notifyListeners();
  }
}
