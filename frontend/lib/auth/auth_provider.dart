import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/oidc_helper/oidc_helper.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/user/user_provider.dart';

class AuthProvider extends BaseProvider<AuthApi> {
  // Helper for OIDC login based around platforms
  final _oidcHelper = OIDCHelper();

  bool _isLoggedIn = false;
  bool _isLoggingOut = false;

  /// Tracks when we're trying to do silent token refresh
  Completer<bool>? _refreshCompleter;

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
    if (tokens[0] != null) map["Authorization"] = 'Bearer ${tokens[0]}';
    if (tokens[1] != null) map["x-access-token"] = tokens[1]!;
    return map;
  }

  /// Given some params, sets the auth information into the secure storage and into the API client
  /// [idToken] The JWT that should be used as the bearer for API auth
  /// [accessToken] The token used for OIDC lookups
  /// [user] Our current user that should be tracked
  Future<User?> _applyAuth(String idToken, User? user, {String? accessToken, String? refreshToken}) async {
    await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, idToken);
    (defaultApiClient.authentication as HttpBearerAuth).accessToken = idToken;
    if (accessToken != null) {
      await SecureStorageProvider.saveValue(SecureStorageProvider.accessToken, accessToken);
      defaultApiClient.addDefaultHeader('x-access-token', accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await SecureStorageProvider.saveValue(SecureStorageProvider.refreshToken, refreshToken);
    }

    _isLoggedIn = true;
    // Populate user based on API endpoint, if we're not given the user
    user ??= await ServiceLocator.get<UserProvider>().api.userControllerMe();
    _currentUser = user;
    return _currentUser;
  }

  /// Public wrapper to manually set tokens
  Future<User?> setTokensInternal({required String idToken, String? accessToken, String? refreshToken}) async {
    return await _applyAuth(idToken, null, accessToken: accessToken, refreshToken: refreshToken);
  }

  /// Grabs the tokens from the secure storage and tries to setup authentication using only those tokens.
  Future<void> applyDefaultAuth() async {
    final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);
    final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken);
    final refreshToken = await SecureStorageProvider.getValue(SecureStorageProvider.refreshToken);
    if (idToken != null) {
      await _applyAuth(idToken, null, accessToken: accessToken, refreshToken: refreshToken);
    }
  }

  Future<User?> tryInitialLogin() async {
    if (_pendingLoginFuture != null) return _pendingLoginFuture!;

    _pendingLoginFuture = () async {
      final configProvider = ServiceLocator.get<ConfigProvider>();
      // Check to make sure we aren't setting up the app.
      if (configProvider.unsecureConfig?.firstTimeSetupPosition == "setup") return null;

      // Grab the token info that is saved in the secure storage
      final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);
      final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken);

      if (configProvider.unsecureConfig?.oidcConfig != null) {
        // OIDC Auth Strategy
        final oidcConfig = configProvider.unsecureConfig!.oidcConfig!;

        // Check if we just came back from a Web Redirect to grab the tokens
        final webTokens = await _oidcHelper.getWebCallbackTokens(
          issuerUrl: oidcConfig.issuer,
          clientId: oidcConfig.clientId,
        );

        if (webTokens != null) {
          // We are returning from login, apply tokens immediately
          await _applyAuth(
            webTokens['id_token']!,
            null,
            accessToken: webTokens['access_token'],
            refreshToken: webTokens['refresh_token'],
          );
          notifyListeners();
          return _currentUser;
        }

        // Standard Session Check
        if (idToken != null) {
          try {
            if (JwtDecoder.isExpired(idToken)) {
              // Token expired: Attempt silent refresh
              final success = await silentRefresh();
              if (success) return _currentUser;
            } else {
              // Token valid: Restore session
              await _applyAuth(idToken, null, accessToken: accessToken);
              return _currentUser;
            }
          } catch (e) {
            await logout();
          }
        }

        // Didn't return from above? Try to hit the login again for OIDC.
        await loginOIDC();
      } else {
        // Local Auth Strategy
        if (idToken != null) {
          try {
            final loginResponse = await api.authControllerLoginWithJWT(JWTLoginRequest(jwt: idToken));
            if (loginResponse != null) await _applyAuth(loginResponse.jwt, loginResponse.user);
          } catch (e) {
            await logout();
          }
        }
      }

      notifyListeners();
      return _currentUser;
    }();

    return _pendingLoginFuture!.whenComplete(() => _pendingLoginFuture = null);
  }

  /// Handles the authentication return from OIDC provider to strip out our tokens we need
  static Future<void> handleAuthReturn() async {
    if (kIsWeb) {
      final configProvider = ServiceLocator.get<ConfigProvider>();
      await configProvider.populateUnsecureConfig();
      final oidcConfig = configProvider.unsecureConfig?.oidcConfig;

      if (oidcConfig != null) {
        final helper = OIDCHelper();
        final tokens = await helper.getWebCallbackTokens(issuerUrl: oidcConfig.issuer, clientId: oidcConfig.clientId);

        if (tokens != null) {
          final authProvider = ServiceLocator.get<AuthProvider>();
          final user = await authProvider.setTokensInternal(
            idToken: tokens['id_token']!,
            accessToken: tokens['access_token'],
            refreshToken: tokens['refresh_token'],
          );
          if (user != null) await ServiceLocator.postLogin();
        }
      }
    }
  }

  Future<User?> loginOIDC() async {
    return _pendingLoginFuture = () async {
      final unsecureConfig = ServiceLocator.get<ConfigProvider>().unsecureConfig;
      if (unsecureConfig?.oidcConfig == null) throw "OIDC is improperly configured.";

      final tokens = await _oidcHelper.authenticate(
        issuerUrl: unsecureConfig!.oidcConfig!.issuer,
        clientId: unsecureConfig.oidcConfig!.clientId,
        scopes: unsecureConfig.oidcConfig!.scopes,
      );

      if (tokens != null) {
        await _applyAuth(
          tokens['id_token']!,
          null,
          accessToken: tokens['access_token'],
          refreshToken: tokens['refresh_token'],
        );
      }
      return _currentUser;
    }();
  }

  /// Local auth login strategy
  Future<User?> login(String username, String password) async {
    final loginResponse = await api.authControllerLogin(
      UsernamePasswordLoginRequest(username: username, password: password),
    );
    if (loginResponse != null) await _applyAuth(loginResponse.jwt, loginResponse.user);

    notifyListeners();
    return _currentUser;
  }

  /// Handles trying to refresh the tokens with the refresh token
  Future<bool> silentRefresh() async {
    // Make sure we don't run these back to back
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    _refreshCompleter = Completer<bool>();
    final refreshToken = await SecureStorageProvider.getValue(SecureStorageProvider.refreshToken);
    if (refreshToken == null) {
      _refreshCompleter!.complete(false);
      return false;
    }

    try {
      // Use the backend to refresh our access with the refresh token
      final response = await api.authControllerRefresh(RefreshRequestDTO(refreshToken: refreshToken));
      if (response != null) {
        await _applyAuth(
          response.idToken,
          null,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        );
        _refreshCompleter!.complete(true);
        return true;
      }
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      LoggerService.error("Refresh token failed: $e");
      await logout();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Fires the logout, no matter what login flow we have
  Future<void> logout({bool forced = false}) async {
    _isLoggingOut = true;
    _currentUser = null;
    await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, null);
    await SecureStorageProvider.saveValue(SecureStorageProvider.accessToken, null);
    await SecureStorageProvider.saveValue(SecureStorageProvider.refreshToken, null);
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
