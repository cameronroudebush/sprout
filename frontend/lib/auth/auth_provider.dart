import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/cookie_provider.dart';
import 'package:sprout/auth/oidc_helper/oidc_helper.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/bg_job_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/user/user_provider.dart';

part 'auth_provider.g.dart';

/// Returns the authApi configured with the proper base path
@Riverpod(keepAlive: true)
Future<AuthApi> authApi(Ref ref) async {
  final client = await ref.watch(baseApiClientProvider.future);
  return AuthApi(client);
}

@Riverpod(keepAlive: true)
class SessionStatus extends _$SessionStatus {
  @override
  bool build() => false;

  void markAsManualLogin() => state = true;
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  /// What OIDC methods are available based on web/mobile
  final _oidcHelper = OIDCHelper();

  /// If we are in a setup mode
  bool isSetupMode = false;

  /// If we're currently logging out
  bool _isLoggingOut = false;

  // Getters for UI
  bool get isLoggingOut => _isLoggingOut;

  @override
  Future<User?> build() async {
    final config = await ref.watch(unsecureConfigProvider.future);
    if (config == null || isSetupMode) return null;

    try {
      final userApi = await ref.read(userApiProvider.future);
      return await userApi.userControllerMe();
    } on ApiException catch (e) {
      if (e.code == 404) await setup();
      return null;
    } catch (e) {
      LoggerProvider.debug("Initial user grab failure: $e");
      return null;
    }
  }

  /// If called, assumes we need to go to setup for new user creation. Runs some initial checks before trying that.
  Future<void> setup() async {
    final config = ref.read(unsecureConfigProvider).value;
    if (config != null && config.allowUserCreation) {
      isSetupMode = true;
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

  /// Private helper to set user info of authenticated user
  Future<User?> _applyAuth({User? user}) async {
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
      ref.read(sessionStatusProvider.notifier).markAsManualLogin();
      return await _applyAuth(user: response);
    }
    return null;
  }

  /// Attempts a login via OIDC using the OIDC helper
  Future<User?> loginOIDC({bool manualLogin = false}) async {
    // Try to restore session from cookies
    if (kIsWeb) {
      try {
        return await _applyAuth();
      } catch (e) {
        LoggerProvider.debug("Cookie restoration failed, proceeding to OIDC redirect.");
      }
    }

    // Full OIDC Authentication
    final basePath = await ref.read(connectionUrlProvider.future);
    await _oidcHelper.authenticate(basePath ?? "", ref);
    ref.read(sessionStatusProvider.notifier).markAsManualLogin();

    return await _applyAuth();
  }

  /// Initiates a logout
  Future<void> logout() async {
    // Ignore requests if this is a background job
    final isBackground = ref.read(isBackgroundJobProvider);
    if (isBackground) return;

    final api = await ref.read(authApiProvider.future);
    _isLoggingOut = true;
    try {
      await api.authControllerLogout();
    } finally {
      // Wipe the CookieJar
      try {
        // We check both persistence flavors just to be safe
        final jar = await ref.read(cookieJarProvider(true).future);
        await jar.deleteAll();
      } catch (e) {
        LoggerProvider.error("Failed to wipe cookie jar: $e");
      }
      // Wipe the state
      state = const AsyncData(null);
      // Invalidate other providers to clear their cache
      ref.invalidate(secureConfigProvider);
      NavigationProvider.redirect("login");
    }
  }

  /// Updates the current user's profile information (e.g., email)
  Future<void> updateUser(UpdateUserDto dto) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final userApi = await ref.read(userApiProvider.future);
      final updatedUser = await userApi.userControllerUpdateMe(dto);
      state = AsyncData(updatedUser);
    } catch (e) {
      LoggerProvider.error("Failed to update user profile: $e");
      rethrow;
    }
  }
}
