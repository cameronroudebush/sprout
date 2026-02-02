import 'dart:async';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:sprout/api/api.dart'; // Assuming this holds your API client
import 'package:sprout/core/logger.dart';

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  @override
  Future<Map<String, String>?> authenticate() async {
    try {
      final backendLoginUrl = "${defaultApiClient.basePath}/auth/oidc/login";
      final callbackScheme = 'net.croudebush.sprout'; // Our own custom callback as defined from the manifest

      final loginUrl = Uri.parse(
        backendLoginUrl,
      ).replace(queryParameters: {'target_url': '$callbackScheme://callback'});

      // Open the Browser and Wait for Result
      final result = await FlutterWebAuth2.authenticate(url: loginUrl.toString(), callbackUrlScheme: callbackScheme);
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
      LoggerService.error('OIDC Auth Error: $e');
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
