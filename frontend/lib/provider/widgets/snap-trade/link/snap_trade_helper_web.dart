import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

import 'snap_trade_helper.dart';

SnapTradeHelper getSnapTradeHelper() => SnapTradeHelperWeb();

class SnapTradeHelperWeb implements SnapTradeHelper {
  @override
  Future<void> linkAccount(
    WidgetRef ref, {
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final redirectUrl = '${html.window.location.origin}/provider-callback.html';
      final api = await ref.read(providerApiProvider.future);
      // Request redirect from backend
      final response = await api.snapTradeProviderControllerGenerateLink(
        redirectUrl: redirectUrl,
      );
      final redirectUri = response;
      if (redirectUri == null) throw Exception("No redirect URI returned");

      // Calculate coordinates to center the popup over the current browser window
      const width = 500;
      const height = 700;
      final windowLeft = html.window.screenX ?? 0;
      final windowTop = html.window.screenY ?? 0;
      final windowWidth = html.window.outerWidth;
      final windowHeight = html.window.outerHeight;
      final left = windowLeft + ((windowWidth - width) ~/ 2);
      final top = windowTop + ((windowHeight - height) ~/ 2);
      final windowFeatures = 'width=$width,height=$height,top=$top,left=$left,status=no,resizable=yes,scrollbars=yes';
      // Open the centered popup
      final popupWindow = html.window.open(redirectUri, 'SnapTrade', windowFeatures);

      // Hold state until SnapTrade sends postMessage or user closes window
      StreamSubscription<html.MessageEvent>? messageSub;
      Timer? pollTimer;

      void cleanup() {
        messageSub?.cancel();
        pollTimer?.cancel();
      }

      // Listen for postMessage from the html file
      messageSub = html.window.onMessage.listen((event) {
        if (event.data == 'PROVIDER_SUCCESS') {
          cleanup();
          onSuccess();
        }
      });

      // Poll to detect if user closed the popup manually
      pollTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (popupWindow.closed ?? true) {
          cleanup();
          // If closed without receiving PROVIDER_SUCCESS, fail gracefully
          onError("SnapTrade connection closed.");
        }
      });
    } catch (e) {
      LoggerProvider.error('SnapTrade Web Auth Error: $e');
      onError(e.toString());
    }
  }
}
