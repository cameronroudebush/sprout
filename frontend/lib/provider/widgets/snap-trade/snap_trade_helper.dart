import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/shared/auth/browser_auth.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

class SnapTradeHelper {
  Future<void> linkAccount(
    WidgetRef ref, {
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final browserAuth = BrowserAuth();
      final api = await ref.read(providerApiProvider.future);

      final redirectUri = await api.snapTradeProviderControllerGenerateLink(
        redirectUrl: browserAuth.callbackUrl,
      );

      if (redirectUri == null) throw Exception("No redirect URI returned");

      // This automatically knows whether to use a popup (Web) or Custom Tab (Mobile)
      await browserAuth.openPopup(
        redirectUri,
        webSuccessMessage: 'PROVIDER_SUCCESS',
      );

      onSuccess();
    } catch (e) {
      LoggerProvider.error('SnapTrade Auth Error: $e');
      onError(e.toString());
    }
  }
}
