import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/auth_token_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/api/auth_interceptor_client.dart';
import 'package:sprout/shared/api/auto_logout_client.dart';
import 'package:sprout/shared/api/base_path_client.dart';
import 'package:sprout/shared/api/browser_client.dart' if (dart.library.html) 'package:http/browser_client.dart';
import 'package:sprout/shared/api/platform_client.dart';
import 'package:sprout/shared/api/timeout_client.dart';

part 'base_api.g.dart';

/// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes
@Riverpod(keepAlive: true)
Future<ApiClient> baseApiClient(Ref ref) async {
  final basePath = await ref.watch(connectionUrlProvider.future);
  final rootClient = _createHttpClient();
  final platformClient = PlatformClient(innerClient: rootClient);
  final timeoutClient = TimeoutClient(innerClient: platformClient, timeout: 5);
  return BasePathClient(client: timeoutClient, basePath: basePath ?? "");
}

/// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]
@Riverpod(keepAlive: true)
Future<ApiClient> baseAuthenticatedClient(Ref ref) async {
  final basePath = await ref.watch(connectionUrlProvider.future);
  final tokens = ref.watch(authTokensProvider).value;
  final rootClient = _createHttpClient();
  final platformClient = PlatformClient(innerClient: rootClient);
  final interceptorClient = AuthInterceptorClient(innerClient: platformClient, ref: ref);

  // Create the AutoLogout wrapper
  final autoLogoutClient = AutoLogoutClient(
    innerClient: interceptorClient,
    onLogout: () async {
      final auth = ref.read(authProvider.notifier);
      final authState = ref.read(authProvider);

      if (authState.value != null) {
        ref
            .read(notificationsProvider.notifier)
            .openFrontendOnly("Session Expired", type: NotificationTypeEnum.warning, duration: 7);
        await auth.logout();
      }
    },
  );

  final auth = HttpBearerAuth();
  if (tokens?.idToken != null && tokens!.idToken!.isNotEmpty) {
    auth.accessToken = tokens.idToken!;
  }

  return BasePathClient(client: autoLogoutClient, basePath: basePath ?? "", authentication: auth);
}

/// Helper to generate the base http client
http.Client _createHttpClient() {
  http.Client inner;
  if (kIsWeb && kDebugMode) {
    inner = BrowserClient()..withCredentials = true;
  } else {
    inner = http.Client();
  }
  return RetryClient(inner, retries: 2);
}
