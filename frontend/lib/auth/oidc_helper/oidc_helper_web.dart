import 'dart:async';
import 'dart:html' as html;

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  @override
  Future<Map<String, String>?> authenticate(String basePath) async {
    final currentUrl = html.window.location.href.split('#').first;
    final path = "$basePath/auth/oidc/login";
    final loginUri = Uri.parse(path).replace(queryParameters: {'target_url': currentUrl});
    html.window.location.assign(loginUri.toString());
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }
}
