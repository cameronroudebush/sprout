import 'dart:async';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  @override
  Future<void> authenticate(String basePath, Ref ref) async {
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
      final tokens = _extractTokens(uri.queryParameters);
      // Exchange for some tasty cookies
      final client = await ref.read(authApiProvider.future);
      if (tokens != null) {
        await client.oIDCControllerExchange(tokens);
      }
    } catch (e) {
      LoggerProvider.error('OIDC Auth Error: $e');
    }
  }

  /// Extracts the tokens from the return of the OIDC request
  MobileTokenExchangeDto? _extractTokens(Map<String, String> params) {
    if (params.containsKey('access_token')) {
      return MobileTokenExchangeDto(
          idToken: params['id_token'] ?? '',
          accessToken: params['access_token'] ?? '',
          refreshToken: params['refresh_token'] ?? '');
    }
    return null;
  }
}
