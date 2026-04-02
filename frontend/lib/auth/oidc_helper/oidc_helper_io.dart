import 'dart:async';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  @override
  Future<Map<String, String>?> authenticate(String basePath) async {
    try {
      final backendLoginUrl = "$basePath/auth/oidc/login";
      final callbackScheme = 'net.croudebush.sprout';

      final loginUrl = Uri.parse(
        backendLoginUrl,
      ).replace(queryParameters: {'target_url': '$callbackScheme://callback'});

      // Open the Browser and Wait for Result
      final result = await FlutterWebAuth2.authenticate(
          url: loginUrl.toString(),
          callbackUrlScheme: callbackScheme,
          options: FlutterWebAuth2Options(
            customTabsPackageOrder: [
              'com.android.chrome',
              'com.chrome.beta',
              'com.sec.android.app.sbrowser',
              'com.brave.browser',
            ],
          ));
      final uri = Uri.parse(result);
      // Pull out our tokens
      String fragment = uri.fragment;

      // Handle cases where the fragment might be parsed as query params depending on the deep link structure
      if (fragment.isEmpty && uri.queryParameters.isNotEmpty) {
        // Fallback if library returns params in query instead of fragment
        final params = uri.queryParameters;
        return _extractTokens(params);
      }

      final params = Uri.splitQueryString(fragment);
      return _extractTokens(params);
    } catch (e) {
      LoggerProvider.error('OIDC Auth Error: $e');
    }
    return null;
  }

  /// Extracts the tokens from the return of the OIDC request
  Map<String, String>? _extractTokens(Map<String, String> params) {
    if (params.containsKey('access_token')) {
      return {
        'id_token': params['id_token'] ?? '',
        'access_token': params['access_token'] ?? '',
        'refresh_token': params['refresh_token'] ?? '',
      };
    }
    return null;
  }
}
