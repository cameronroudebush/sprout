import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;
import 'package:openid_client/openid_client_io.dart' as io;
import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/user/user_provider.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;

/// This provider handles all authentication layer requirements
class AuthProvider extends BaseProvider<AuthApi> {
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  /// Redirection URL for what to do after we authenticate
  Uri get _redirectUri {
    if (kIsWeb) return Uri.parse('${html.window.location.origin}/auth_callback.html');
    return Uri.parse('net.croudebush.sprout://auth_callback');
  }

  AuthProvider(super.api);

  /// Given some params, sets the auth information into the secure storage and into the API client
  /// [idToken] The JWT that should be used as the bearer for API auth
  /// [accessToken] The token used for OIDC lookups
  /// [user] Our current user that should be tracked
  Future<void> _applyAuth(String idToken, User? user, String? accessToken) async {
    await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, idToken);
    // Set the ID Token as the Bearer for JWT validation
    (defaultApiClient.authentication as HttpBearerAuth).accessToken = idToken;

    // Set the Access Token as a Custom Header
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
    final configProvider = ServiceLocator.get<ConfigProvider>();

    // Check to make sure we aren't setting up the app.
    if (configProvider.unsecureConfig?.firstTimeSetupPosition == "setup") return null;

    // Grab the JWT that is saved in the secure storage
    final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);
    final accessToken = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken);

    // Try to auto authenticate, if we can
    if (configProvider.unsecureConfig?.oidcConfig != null) {
      if (idToken == null) {
        // No token, check if this is from the web callback and grab the token there.
        final callbackAT = html.window.sessionStorage['access_token'];
        final callbackID = html.window.sessionStorage['id_token'];

        if (callbackID != null) {
          // This is the callback from the authentication redirect for OIDC. Apply the necessary data.

          // Cleanup tokens so they only live in the secure storage
          html.window.sessionStorage.remove('access_token');
          html.window.sessionStorage.remove('id_token');
          await _applyAuth(callbackID, null, callbackAT);
        } else {
          // This is not a callback from the redirect. Try and force a login.
          await loginOIDC();
        }
      } else {
        // We have a token so lets track it
        await _applyAuth(idToken, null, accessToken);
      }
    } else {
      // Automatically login with local JWT only
      if (idToken != null) {
        try {
          final loginResponse = await api.authControllerLoginWithJWT(JWTLoginRequest(jwt: idToken));
          if (loginResponse != null) await _applyAuth(loginResponse.jwt, loginResponse.user, null);
        } catch (e) {
          // Token is probably invalid
          await logout();
        }
      }
    }

    notifyListeners();
    return _currentUser;
  }

  /// Triggers the OIDC Login Flow
  Future<void> loginOIDC() async {
    final unsecureConfig = ServiceLocator.get<ConfigProvider>().unsecureConfig;

    if (unsecureConfig == null || unsecureConfig.oidcConfig == null) throw "OIDC is improperly configured.";
    final issuerUrl = unsecureConfig.oidcConfig!.issuer;
    final clientId = unsecureConfig.oidcConfig!.clientId;
    final scopes = unsecureConfig.oidcConfig!.scopes;

    // Create our client and get the OIDC endpoint
    Issuer issuer;
    if (kIsWeb) {
      issuer = await browser.Issuer.discover(Uri.parse(issuerUrl));
    } else {
      issuer = await io.Issuer.discover(Uri.parse(issuerUrl));
    }

    final client = Client(issuer, clientId);

    // Create our login flow based on the current client
    if (kIsWeb) {
      final flow = Flow.implicit(client)
        ..scopes.addAll(scopes)
        ..redirectUri = _redirectUri;
      // Redirect the browser
      html.window.location.href = flow.authenticationUri.toString();
    } else {
      final flow = Flow.authorizationCodeWithPKCE(client)
        ..scopes.addAll(scopes)
        ..redirectUri = _redirectUri;

      // Launch system browser
      await launchUrl(flow.authenticationUri, mode: LaunchMode.externalApplication);

      // Listen for the user to come back
      // TODO
      // _listenForMobileCallback(flow);
    }
  }

  // /// This function is used to catch app links so we end up back within the app
  // void _listenForMobileCallback(Flow flow) {
  //   final _appLinks = AppLinks();
  //   StreamSubscription? sub;

  //   sub = _appLinks.uriLinkStream.listen((Uri? uri) async {
  //     if (uri != null && uri.scheme == _redirectUri.scheme) {
  //       try {
  //         // Exchange the code for tokens
  //         final credential = await flow.callback(uri.queryParameters);
  //         final tokenResponse = await credential.getTokenResponse();

  //         // TODO
  //         print("Mobile Access Token: ${tokenResponse.accessToken}");

  //         await _applyJWT(tokenResponse.accessToken.toString());
  //         _isLoggedIn = true;
  //         notifyListeners();

  //         sub?.cancel(); // Stop listening after success
  //       } catch (e) {
  //         print("Mobile Auth Error: $e");
  //       }
  //     }
  //   });
  // }

  /// Login flow expecting non OIDC setup in the backend
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
}
