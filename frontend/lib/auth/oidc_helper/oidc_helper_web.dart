import 'dart:html' as html;

import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  @override
  Map<String, String>? getWebCallbackTokens() {
    final callbackAT = html.window.sessionStorage['access_token'];
    final callbackID = html.window.sessionStorage['id_token'];

    if (callbackID != null) {
      // Clean up storage
      html.window.sessionStorage.remove('access_token');
      html.window.sessionStorage.remove('id_token');
      return {'id_token': callbackID, 'access_token': callbackAT ?? ''};
    }
    return null;
  }

  @override
  Future<Map<String, String>?> authenticate({
    required String issuerUrl,
    required String clientId,
    required List<String> scopes,
  }) async {
    // Discover
    final issuer = await browser.Issuer.discover(Uri.parse(issuerUrl));
    final client = Client(issuer, clientId);

    // Create Flow
    final flow = Flow.implicit(client)
      ..scopes.addAll(scopes)
      ..redirectUri = Uri.parse('${html.window.location.origin}/auth_callback.html');

    // Execute
    html.window.location.href = flow.authenticationUri.toString();

    // Web flow ends here as page redirects
    return null;
  }
}
