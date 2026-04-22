import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

import 'oidc_helper_stub.dart' as stub;

class OIDCHelper implements stub.OIDCHelper {
  /// Generates a random string for use in our PKCE implementation
  String _generateRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  @override
  Future<void> authenticate(String basePath, Ref ref) async {
    try {
      final backendLoginUrl = "$basePath/auth/oidc/login";
      final callbackScheme = 'net.croudebush.sprout';
      final appVerifier = _generateRandomString(43);

      // Hash this to create a challenge
      final bytes = utf8.encode(appVerifier);
      final digest = sha256.convert(bytes);
      final appChallenge = base64UrlEncode(digest.bytes).replaceAll('=', '');

      final loginUrl = Uri.parse(
        backendLoginUrl,
      ).replace(queryParameters: {
        'target_url': '$callbackScheme://callback',
        'app_challenge': appChallenge,
      });

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
      final handoffCode = uri.queryParameters['code'];
      // Exchange for some tasty cookies
      final client = await ref.read(authApiProvider.future);
      if (handoffCode != null) {
        await client.oIDCControllerExchange(MobileTokenExchangeDto(appVerifier: appVerifier, code: handoffCode));
      } else {
        throw Exception("Failed to parse handoff code from ODIC.");
      }
    } catch (e) {
      LoggerProvider.error('OIDC Auth Error: $e');
    }
  }
}
