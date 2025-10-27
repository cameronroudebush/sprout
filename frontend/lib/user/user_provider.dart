import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:sprout/core/provider/storage.dart';

class UserProvider extends BaseProvider<UserApi> {
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  UserProvider(super.api);

  /// Sets the JWT into the API client and saves it to the secure storage for auto re-login
  Future<void> _applyJWT(String jwt) async {
    await SecureStorageProvider.saveValue(SecureStorageProvider.jwtKey, jwt);
    (defaultApiClient.authentication as HttpBearerAuth).accessToken = jwt;
  }

  /// Used to try to auto login if we have a JWT available
  Future<User?> checkInitialLoginStatus() async {
    // Don't try to auto login when in setup if the user reset their db.
    final configProvider = ServiceLocator.get<ConfigProvider>();
    if (configProvider.unsecureConfig?.firstTimeSetupPosition == "setup") return null;
    final currentJwt = await SecureStorageProvider.getValue(SecureStorageProvider.jwtKey);
    if (currentJwt != null) {
      final loginResponse = await api.userControllerLoginWithJWT(JWTLoginRequest(jwt: currentJwt));
      if (loginResponse != null) {
        _currentUser = loginResponse.user;
        await _applyJWT(loginResponse.jwt);
        _isLoggedIn = true;
      }
    }
    notifyListeners();
    return _currentUser;
  }

  Future<User?> login(String username, String password) async {
    final loginResponse = await api.userControllerLogin(
      UsernamePasswordLoginRequest(username: username, password: password),
    );
    if (loginResponse != null) {
      _currentUser = loginResponse.user;
      await _applyJWT(loginResponse.jwt);
      _isLoggedIn = true;
    }
    notifyListeners();
    return _currentUser;
  }

  Future<String?> createUser(String username, String password) async {
    final response = await api.userControllerCreate(UserCreationRequest(username: username, password: password));
    return response?.username;
  }

  Future<void> logout({bool forced = false}) async {
    if (forced) {
      SnackbarProvider.openSnackbar("You have been logged out", type: SnackbarType.warning);
    }
    // Wipe the JWT so auto logins are not performed
    // TODO: Add actual logout tracking to the backend to invalidate the JWT?
    await SecureStorageProvider.saveValue(SecureStorageProvider.jwtKey, null);
    _isLoggedIn = false;
    for (final provider in ServiceLocator.getAllProviders()) {
      await provider.cleanupData();
    }
    SproutNavigator.redirect("login");
    notifyListeners();
  }
}
