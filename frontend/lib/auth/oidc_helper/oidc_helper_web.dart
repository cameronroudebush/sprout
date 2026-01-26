import 'dart:async';
import 'dart:html' as html;

import 'package:sprout/api/api.dart';

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
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
