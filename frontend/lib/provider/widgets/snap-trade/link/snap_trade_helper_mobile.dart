import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

import 'snap_trade_helper.dart';

SnapTradeHelper getSnapTradeHelper() => SnapTradeHelperMobile();

class SnapTradeHelperMobile implements SnapTradeHelper {
  @override
  Future<void> linkAccount(
    WidgetRef ref, {
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      const callbackScheme = 'net.croudebush.sprout';
      const redirectUrl = '$callbackScheme://callback';

      final api = await ref.read(providerApiProvider.future);
      final response = await api.snapTradeProviderControllerGenerateLink(
        redirectUrl: redirectUrl,
      );

      final redirectUri = response;
      if (redirectUri == null) throw Exception("No redirect URI returned");

      await FlutterWebAuth2.authenticate(
        url: redirectUri,
        callbackUrlScheme: callbackScheme,
        options: const FlutterWebAuth2Options(
          customTabsPackageOrder: [
            'com.android.chrome',
            'com.chrome.beta',
            'com.sec.android.app.sbrowser',
            'com.brave.browser',
          ],
        ),
      );

      onSuccess();
    } catch (e) {
      LoggerProvider.error('SnapTrade Mobile Auth Error: $e');
      onError(e.toString());
    }
  }
}
