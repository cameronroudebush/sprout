import 'dart:async';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/logger.dart';

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  @override
  Future<Map<String, String>?> getWebCallbackTokens({required String issuerUrl, required String clientId}) async {
    return null;
  }

  @override
  Future<Map<String, String>?> authenticate({
    required String issuerUrl,
    required String clientId,
    required List<String> scopes,
  }) async {
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
      String? fragment = uri.fragment;
      final params = Uri.splitQueryString(fragment);
      if (params.containsKey('access_token')) {
        return {
          'id_token': params['id_token'] ?? '',
          'access_token': params['access_token'] ?? '',
          'refresh_token': params['refresh_token'] ?? '',
        };
      }
    } catch (e) {
      LoggerService.error('OIDC Auth Error: $e');
    }
    return null;
  }
}
