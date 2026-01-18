import 'dart:async';

import 'package:sprout/api/api.dart';
import 'package:sprout/auth/oidc_helper/oidc_helper.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/user/user_provider.dart';

class AuthProvider extends BaseProvider<AuthApi> {
  // Helper for OIDC login based around platforms
  final _oidcHelper = OIDCHelper();

  bool _isLoggedIn = false;
  bool _isLoggingOut = false;

  /// Helps track if we're in the middle of a login or not for OIDC. Mostly used for mobile issues.
  Future<User?>? _pendingLoginFuture;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  AuthProvider(super.api);

  /// Asynchronously fetches both the ID Token and Access Token and places them into a header object
  ///   as required by the authentication in the backend. Handles both local and OIDC strategies.
  Future<Map<String, String>> getHeaders() async {
    final tokens = await Future.wait([
      SecureStorageProvider.getValue(SecureStorageProvider.idToken),
      SecureStorageProvider.getValue(SecureStorageProvider.accessToken),
    ]);
    Map<String, String> map = {};
    // Id token
    if (tokens[0] != null) map["Authorization"] = 'Bearer ${tokens[0]}';
    // Access token
    if (tokens[1] != null) map["x-access-token"] = tokens[1]!;
    return map;
  }

  /// Given some params, sets the auth information into the secure storage and into the API client
  /// [idToken] The JWT that should be used as the bearer for API auth
  /// [accessToken] The token used for OIDC lookups
  /// [user] Our current user that should be tracked
  Future<void> _applyAuth(String idToken, User? user, String? accessToken) async {
    await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, idToken);
    (defaultApiClient.authentication as HttpBearerAuth).accessToken = idToken;
    if (accessToken != null) {
      await SecureStorageProvider.saveValue(SecureStorageProvider.accessToken, accessToken);
      defaultApiClient.addDefaultHeader('x-access-token', accessToken);
    }

    _isLoggedIn = true;
    // Populate user based on API endpoint, if we're not given the user
    user ??= await ServiceLocator.get<UserProvider>().api.userControllerMe();
    _currentUser = user;
  }

  /// Used to try our initial login requirements
  Future<User?> tryInitialLogin() async {
    if (_pendingLoginFuture != null) {
      return _pendingLoginFuture!;
    }

    _pendingLoginFuture = () async {
      final configProvider = ServiceLocator.get<ConfigProvider>();
      // Check to make sure we aren't setting up the app.
      if (configProvider.unsecureConfig?.firstTimeSetupPosition == "setup") return null;

      // Grab the token info that is saved in the secure storage
      final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);
      final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken);

      if (configProvider.unsecureConfig?.oidcConfig != null) {
        // OIDC Strategy
        if (idToken == null) {
          final webTokens = _oidcHelper.getWebCallbackTokens();

          if (webTokens != null) {
            await _applyAuth(webTokens['id_token']!, null, webTokens['access_token']);
          } else {
            // No tokens found, try login
            await loginOIDC();
          }
        } else {
          // We have a token so lets track it
          await _applyAuth(idToken, null, accessToken);
        }
      } else {
        // Local Auth Strategy
        if (idToken != null) {
          try {
            final loginResponse = await api.authControllerLoginWithJWT(JWTLoginRequest(jwt: idToken));
            if (loginResponse != null) await _applyAuth(loginResponse.jwt, loginResponse.user, null);
          } catch (e) {
            await logout();
          }
        }
      }

      notifyListeners();
      return _currentUser;
    }();

    return _pendingLoginFuture!.whenComplete(() {
      _pendingLoginFuture = null;
    });
  }

  /// Triggers the OIDC Login Flow
  Future<User?> loginOIDC() async {
    return _pendingLoginFuture = () async {
      final unsecureConfig = ServiceLocator.get<ConfigProvider>().unsecureConfig;
      if (unsecureConfig?.oidcConfig == null) throw "OIDC is improperly configured.";

      final tokens = await _oidcHelper.authenticate(
        issuerUrl: unsecureConfig!.oidcConfig!.issuer,
        clientId: unsecureConfig.oidcConfig!.clientId,
        scopes: unsecureConfig.oidcConfig!.scopes,
      );

      // Mobile flow will apply tokens in here
      if (tokens != null) {
        await _applyAuth(tokens['id_token']!, null, tokens['access_token']);
      }
      return _currentUser;
    }();
  }

  /// Local auth login strategy
  Future<User?> login(String username, String password) async {
    final loginResponse = await api.authControllerLogin(
      UsernamePasswordLoginRequest(username: username, password: password),
    );
    if (loginResponse != null) await _applyAuth(loginResponse.jwt, loginResponse.user, null);

    notifyListeners();
    return _currentUser;
  }

  /// Fires the logout, no matter what login flow we have
  Future<void> logout({bool forced = false}) async {
    _isLoggingOut = true;
    if (forced) SnackbarProvider.openSnackbar("You have been logged out", type: SnackbarType.warning);

    // Wipe data
    _currentUser = null;
    await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, null);
    await SecureStorageProvider.saveValue(SecureStorageProvider.accessToken, null);

    _isLoggedIn = false;
    for (final provider in ServiceLocator.getAllProviders()) {
      await provider.cleanupData();
    }
    StateTracker.lastUpdateTimes = {};
    SproutNavigator.redirect("login");
    notifyListeners();
  }

  /// Used to consume that we are logging out so we don't immediately try to re-login (especially with OIDC)
  bool get consumeLogoutEvent {
    if (_isLoggingOut) {
      _isLoggingOut = false;
      return true;
    }
    return false;
  }
}
