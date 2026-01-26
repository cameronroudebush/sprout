import 'dart:async';
import 'dart:html' as html;

import 'package:sprout/api/api.dart';

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  @override
  Future<Map<String, String>?> getWebCallbackTokens({required String issuerUrl, required String clientId}) async {
    final fragment = html.window.location.hash;

    if (fragment.isEmpty) return null;

    // Remove the leading '#' and parse query string format
    final cleanFragment = fragment.startsWith('#') ? fragment.substring(1) : fragment;
    final params = Uri.splitQueryString(cleanFragment);

    if (params.containsKey('access_token')) {
      // Clear the URL so tokens don't linger in the address bar
      html.window.history.replaceState(null, '', html.window.location.pathname);

      return {
        'id_token': params['id_token'] ?? '',
        'access_token': params['access_token'] ?? '',
        'refresh_token': params['refresh_token'] ?? '',
      };
    }

    return null;
  }

  @override
  Future<Map<String, String>?> authenticate({
    required String issuerUrl,
    required String clientId,
    required List<String> scopes,
  }) async {
    final currentUrl = html.window.location.href.split('#').first;
    final path = "${defaultApiClient.basePath}/auth/oidc/login";
    final loginUri = Uri.parse(path).replace(queryParameters: {'target_url': currentUrl});
    html.window.location.assign(loginUri.toString());
    return null;
  }
}
