import 'package:sprout/auth/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/model/user.dart';

class AuthProvider extends BaseProvider<AuthAPI> {
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  AuthProvider(super.api);

  /// Used to try to auto login if we have a JWT available
  Future<void> _checkInitialLoginStatus() async {
    // Don't try to auto login when in setup if the user reset their db.
    final configProvider = ServiceLocator.get<ConfigProvider>();
    if (configProvider.unsecureConfig?.firstTimeSetupPosition == "setup") return;
    User? user = await api.loginWithJWT(null);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<User?> login(String username, String password) async {
    User? user = await api.loginWithPassword(username, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
    }
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    await api.logout();
    _isLoggedIn = false;
    notifyListeners();
  }

  @override
  Future<void> onInit() async {
    _checkInitialLoginStatus();
  }
}
