import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_token_provider.dart';
import 'package:sprout/auth/oidc_helper/oidc_helper.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';
import 'package:sprout/user/user_provider.dart';

part 'auth_provider.g.dart';

/// Returns the authApi configured with the proper base path
@Riverpod(keepAlive: true)
Future<AuthApi> authApi(Ref ref) async {
  final client = await ref.watch(baseApiClientProvider.future);
  return AuthApi(client);
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  /// What OIDC methods are available based on web/mobile
  final _oidcHelper = OIDCHelper();

  /// If we are in a setup mode
  bool isSetupMode = false;

  /// If we're currently logging out
  bool _isLoggingOut = false;

  /// Used to prevent duplicate OIDC refresh requests
  Completer<bool>? _refreshCompleter;

  // Getters for UI
  bool get isLoggingOut => _isLoggingOut;

  @override
  Future<User?> build() async {
    final config = await ref.watch(unsecureConfigProvider.future);
    final tokens = await ref.read(authTokensProvider.future);

    if (config == null) return null;

    // OIDC
    if (config.authMode == UnsecureAppConfigurationAuthModeEnum.oidc) {
      // Mobile - Restore
      if (!kIsWeb && tokens.idToken != null) {
        if (JwtDecoder.isExpired(tokens.idToken!)) {
          final user = await loginOIDC();
          if (user != null) {
            return user;
          } else {
            return null;
          }
        } else {
          return await _applyAuth(
            idToken: tokens.idToken,
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
        }
      } else if (kIsWeb) {
        // Web - Restore
        return await _applyAuth();
      }

      // Base case. Don't try to auto login to prevent loops from failures
      return null;
    }

    // Local Auth Restore (Mobile & Web)
    try {
      // Try and grab me as a user if we have a token to see if this needs to be a new user setup
      if ((tokens.idToken == null || tokens.idToken == "") && config.allowUserCreation) {
        try {
          final api = await ref.read(userApiProvider.future);
          await api.userControllerMe();
        } catch (e) {
          if (e is ApiException && e.code == 404) await setup();
        }
      } else {
        final api = await ref.read(authApiProvider.future);
        final loginResponse = await api.authControllerLoginWithJWT(JWTLoginRequest(jwt: tokens.idToken ?? ''));
        if (loginResponse != null) return await _applyAuth(idToken: loginResponse.jwt, user: loginResponse.user);
      }
    } on ApiException catch (e, _) {
      final isSessionExpiration = e.code == 401;
      // Reset the JWT as the auto login has expired
      if (isSessionExpiration) {
        await ref.read(authTokensProvider.notifier).clear();
      }
      // Either no cookie so not logged in, or an invalid JWT
      return null;
    }

    return null;
  }

  /// Grabs the tokens from the secure storage and tries to setup authentication using only those tokens.
  Future<void> applyDefaultAuth() async {
    final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);
    final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken);
    final refreshToken = await SecureStorageProvider.getValue(SecureStorageProvider.refreshToken);
    if (idToken != null) {
      await _applyAuth(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken);
    }
  }

  /// If called, assumes we need to go to setup for new user creation. Runs some initial checks before trying that.
  Future<void> setup() async {
    isSetupMode = true;
    final config = ref.read(unsecureConfigProvider).value;
    if (config != null && config.allowUserCreation) {
      LoggerProvider.debug("Initiating setup for new user with strategy ${config.authMode.toString()}.");
      NavigationProvider.redirect("setup");
    }
  }

  /// What to do when setup is done
  Future<void> completeSetup() async {
    isSetupMode = false;
    state = AsyncData(state.value);
    // Force refresh the unsecure config to pick up post-setup settings
    // ignore: unused_result
    await ref.refresh(unsecureConfigProvider.future);
    NavigationProvider.redirect("/");
  }

  /// Private helper to set tokens and update the state
  Future<User?> _applyAuth({String? idToken, String? accessToken, String? refreshToken, User? user}) async {
    await ref
        .read(authTokensProvider.notifier)
        .updateTokens(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken);
    final userApi = await ref.read(userApiProvider.future);
    final finalUser = user ?? await userApi.userControllerMe();
    state = AsyncData(finalUser);
    return finalUser;
  }

  /// Fires a login using username/password given
  Future<User?> login(String username, String password) async {
    final api = await ref.read(authApiProvider.future);
    final response = await api.authControllerLogin(
      UsernamePasswordLoginRequest(username: username, password: password),
    );
    if (response != null) {
      return await _applyAuth(idToken: response.jwt, user: response.user);
    }
    return null;
  }

  /// Attempts a login via OIDC using the OIDC helper
  Future<User?> loginOIDC() async {
    final tokens = await _oidcHelper.authenticate();
    if (!kIsWeb && tokens != null) {
      return await _applyAuth(
        idToken: tokens['id_token'],
        accessToken: tokens['access_token'],
        refreshToken: tokens['refresh_token'],
      );
    } else if (kIsWeb) {
      return await _applyAuth();
    }
    return null;
  }

  /// Initiates a logout
  Future<void> logout() async {
    final api = await ref.read(authApiProvider.future);
    _isLoggingOut = true;
    try {
      await api.authControllerLogout();
    } finally {
      await ref.read(authTokensProvider.notifier).clear();
      // Wipe the state
      state = const AsyncData(null);
      // Invalidate other providers to clear their cache
      ref.invalidate(secureConfigProvider);
      NavigationProvider.redirect("login");
    }
  }

  /// Adds required tokens via headers for authentication.
  Future<Map<String, String>> getHeaders() async {
    // Web uses cookies
    if (kIsWeb) return {};
    final tokens = ref.read(authTokensProvider).value;
    return {"Authorization": 'Bearer ${tokens?.idToken ?? ""}', 'x-access-token': tokens?.accessToken ?? ""};
  }

  /// Handles trying to refresh the tokens with the refresh token
  Future<bool> silentRefresh() async {
    // If a refresh is already in progress, return the existing future
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    _refreshCompleter = Completer<bool>();

    try {
      final config = ref.read(unsecureConfigProvider).value;

      // Strategy Check (OIDC vs Local)
      // If not OIDC, we can't refresh (Local strategy usually requires a re-login)
      final isOIDC = config?.authMode == UnsecureAppConfigurationAuthModeEnum.oidc;
      if (!isOIDC) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Token Acquisition
      final tokens = ref.read(authTokensProvider).value;
      final refreshToken = kIsWeb ? "" : tokens?.refreshToken;

      if (!kIsWeb && (refreshToken == null || refreshToken.isEmpty)) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final authApi = await ref.read(authApiProvider.future);
      final response = await authApi.authControllerRefresh(RefreshRequestDTO(refreshToken: refreshToken ?? ""));

      if (response != null) {
        if (!kIsWeb) {
          // Update storage with the new tokens
          await _applyAuth(accessToken: response.accessToken, refreshToken: response.refreshToken);
        } else {
          // Web cookies are updated automatically by the browser/server
          state = AsyncData(state.value); // Refresh state to notify listeners
        }
        _refreshCompleter!.complete(true);
        return true;
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      LoggerProvider.error("Refresh failed: $e");
      // If refresh fails, we must log out to clear the "stuck" state
      await logout();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
