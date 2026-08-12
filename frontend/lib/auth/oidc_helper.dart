import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/auth/browser_auth.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

class OIDCHelper {
  String _generateRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  Future<void> authenticate(String basePath, Ref ref) async {
    try {
      final browserAuth = BrowserAuth();
      final backendLoginUrl = "$basePath/auth/oidc/login";

      // Web Flow (Simple Tab Redirect)
      if (kIsWeb) {
        final loginUri = Uri.parse(backendLoginUrl).replace(
          queryParameters: {'target_url': browserAuth.currentWebUrl},
        );
        await browserAuth.redirectTab(loginUri.toString());
        return;
      }

      // Mobile Flow (PKCE + Custom Tab + Code Exchange)
      final appVerifier = _generateRandomString(43);
      final bytes = utf8.encode(appVerifier);
      final digest = sha256.convert(bytes);
      final appChallenge = base64UrlEncode(digest.bytes).replaceAll('=', '');

      final loginUrl = Uri.parse(backendLoginUrl).replace(queryParameters: {
        'target_url': browserAuth.callbackUrl,
        'app_challenge': appChallenge,
      });

      // Wait for Custom Tab to return the redirect URL
      final result = await browserAuth.openPopup(loginUrl.toString());
      final uri = Uri.parse(result);
      final handoffCode = uri.queryParameters['code'];

      if (handoffCode == null) throw Exception("Failed to parse handoff code from OIDC.");

      final client = await ref.read(authApiProvider.future);
      await client.oIDCControllerExchange(
        MobileTokenExchangeDto(appVerifier: appVerifier, code: handoffCode),
      );
    } catch (e) {
      LoggerProvider.error('OIDC Auth Error: $e');
    }
  }
}
