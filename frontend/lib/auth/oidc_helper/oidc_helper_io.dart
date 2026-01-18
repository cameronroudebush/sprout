import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_io.dart' as io;
import 'package:sprout/auth/oidc_helper/oidc_helper_stub.dart' as stub;
import 'package:url_launcher/url_launcher.dart';

class OIDCHelper implements stub.OIDCHelper {
  @override
  Map<String, String>? getWebCallbackTokens() {
    // Android doesn't use session storage for callbacks
    return null;
  }

  @override
  Future<Map<String, String>?> authenticate({
    required String issuerUrl,
    required String clientId,
    required List<String> scopes,
  }) async {
    // Create the client
    final issuer = await io.Issuer.discover(Uri.parse(issuerUrl));
    final client = Client(issuer, clientId);
    final redirectUri = Uri.parse('net.croudebush.sprout://auth_callback');

    final flow = Flow.authorizationCodeWithPKCE(client)
      ..scopes.addAll(scopes)
      ..redirectUri = redirectUri;

    // Set up the listener *before* launching the browser
    final appLinks = AppLinks();
    final completer = Completer<Map<String, String>?>();
    StreamSubscription? sub;

    sub = appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.toString().startsWith(redirectUri.toString())) {
        try {
          // Exchange the code for the actual tokens
          final credential = await flow.callback(uri.queryParameters);
          final tokens = await credential.getTokenResponse();

          completer.complete({
            'id_token': tokens.idToken.toCompactSerialization(),
            'access_token': tokens.accessToken ?? '',
          });
        } catch (e) {
          completer.completeError(e);
        } finally {
          // Stop listening once we have the tokens
          sub?.cancel();
        }
      }
    });

    // Launch the System Browser
    await launchUrl(flow.authenticationUri, mode: LaunchMode.externalApplication);
    // Wait for the user to return from the login
    return completer.future;
  }
}
