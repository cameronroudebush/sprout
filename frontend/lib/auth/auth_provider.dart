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
    // Web uses cookies
    if (kIsWeb) return {'x-client-platform': 'web'};

    final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken) ?? '';
    final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken) ?? '';
    return {"Authorization": 'Bearer $idToken', 'x-access-token': accessToken, 'x-client-platform': 'mobile'};
  }

  /// Given some params, sets the auth information into the secure storage and into the API client
  Future<User?> _applyAuth({String? idToken, String? accessToken, String? refreshToken, User? user}) async {
    try {
      // Web never saves tokens as we only use cookies
      if (kIsWeb) {
        _isLoggedIn = true;
        // Just ensure we have the user
        user ??= await ServiceLocator.get<UserProvider>().api.userControllerMe();
        _currentUser = user;
        return _currentUser;
      }

      // Mobile always save tokens so populate them
      if (idToken != null) {
        await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, idToken);
        (defaultApiClient.authentication as HttpBearerAuth).accessToken = idToken;
      }
      if (accessToken != null) await SecureStorageProvider.saveValue(SecureStorageProvider.accessToken, accessToken);
      if (refreshToken != null) await SecureStorageProvider.saveValue(SecureStorageProvider.refreshToken, refreshToken);

      _isLoggedIn = true;
      _currentUser = user ?? await ServiceLocator.get<UserProvider>().api.userControllerMe();
      return _currentUser;
    } catch (e) {
      // Logout on errors
      await logout(forced: true);
      return null;
    }
  }

  /// Grabs the tokens from the secure storage and tries to setup authentication using only those tokens.
  ///   This is intended to be used via mobile for OIDC strategy
  Future<void> applyDefaultAuth() async {
    final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);
    final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken);
    final refreshToken = await SecureStorageProvider.getValue(SecureStorageProvider.refreshToken);
    if (idToken != null) {
      await _applyAuth(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken);
    }
  }

  Future<User?> tryInitialLogin() async {
    if (_pendingLoginFuture != null) return _pendingLoginFuture!;

    _pendingLoginFuture = () async {
      final configProvider = ServiceLocator.get<ConfigProvider>();
      if (configProvider.unsecureConfig?.firstTimeSetupPosition == "setup") return null;

      // Load Tokens
      final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);

      // OIDC
      if (configProvider.unsecureConfig?.oidcConfig != null) {
        // Mobile - Restore
        if (!kIsWeb && idToken != null) {
          final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken); // OIDC Mobile
          final refreshToken = await SecureStorageProvider.getValue(SecureStorageProvider.refreshToken); // OIDC Mobile
          if (JwtDecoder.isExpired(idToken)) {
            final user = await loginOIDC();
            if (user != null) {
              return user;
            } else {
              return null;
            }
          } else {
            return await _applyAuth(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken);
          }
        } else if (kIsWeb) {
          // Web - Restore
          try {
            // Attempt to fetch 'me'. If we have a cookie, this succeeds.
            final user = await ServiceLocator.get<UserProvider>().api.userControllerMe();
            _isLoggedIn = true;
            _currentUser = user;
            return user;
          } catch (e) {
            // No cookie, no headers -> Not logged in.
          }
        }

        // Didn't return from above? Try to hit the login again for OIDC.
        return await loginOIDC();
      }

      // Local Auth Restore (Mobile & Web)
      try {
        final loginResponse = await api.authControllerLoginWithJWT(JWTLoginRequest(jwt: idToken ?? ''));
        if (loginResponse != null) return await _applyAuth(idToken: loginResponse.jwt, user: loginResponse.user);
      } catch (e) {
        // Either no cookie so not logged in, or an invalid JWT
      }

      return null;
    }();

    return _pendingLoginFuture!.whenComplete(() => _pendingLoginFuture = null);
  }

  Future<User?> loginOIDC() async {
    return _pendingLoginFuture = () async {
      final unsecureConfig = ServiceLocator.get<ConfigProvider>().unsecureConfig;
      if (unsecureConfig?.oidcConfig == null) throw "OIDC Config missing";

      final tokens = await _oidcHelper.authenticate(
        issuerUrl: unsecureConfig!.oidcConfig!.issuer,
        clientId: unsecureConfig.oidcConfig!.clientId,
        scopes: unsecureConfig.oidcConfig!.scopes,
      );

      // On Web, tokens is null (Cookie flow).
      // On Mobile, tokens contains data.
      if (!kIsWeb && tokens != null) {
        await _applyAuth(
          idToken: tokens['id_token'],
          accessToken: tokens['access_token'],
          refreshToken: tokens['refresh_token'],
        );
      } else if (kIsWeb) {
        // We assume cookies are set. Just fetch user.
        await _applyAuth();
      }

      return _currentUser;
    }();
  }

  /// Local auth login strategy
  Future<User?> login(String username, String password) async {
    final loginResponse = await api.authControllerLogin(
      UsernamePasswordLoginRequest(username: username, password: password),
    );
    if (loginResponse != null) await _applyAuth(idToken: loginResponse.jwt, user: loginResponse.user);

    notifyListeners();
    return _currentUser;
  }

  /// Handles trying to refresh the tokens with the refresh token
  Future<bool> silentRefresh() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    _refreshCompleter = Completer<bool>();

    try {
      final configProvider = ServiceLocator.get<ConfigProvider>();
      // Not OIDC? Then just complete. We can't refresh with local strategy
      if (configProvider.unsecureConfig?.oidcConfig == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Mobile: Load from storage. Web: Send empty string (Backend checks cookie).
      final refreshToken = kIsWeb ? "" : await SecureStorageProvider.getValue(SecureStorageProvider.refreshToken);

      if (!kIsWeb && refreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await api.authControllerRefresh(RefreshRequestDTO(refreshToken: refreshToken ?? ""));

      if (response != null) {
        if (!kIsWeb) {
          await _applyAuth(accessToken: response.accessToken, refreshToken: response.refreshToken);
        } else {
          // Web cookies updated automatically
          _isLoggedIn = true;
        }
        _refreshCompleter!.complete(true);
        return true;
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      LoggerService.error("Refresh failed: $e");
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

    // Tell the backend about the logout
    await api.authControllerLogout();

    // Cleanup storage
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
