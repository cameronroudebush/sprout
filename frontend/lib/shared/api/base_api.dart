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
import 'package:sprout/shared/api/browser_client.dart' if (dart.library.html) 'package:http/browser_client.dart';
import 'package:sprout/shared/api/platform_client.dart';

part 'base_api.g.dart';

/// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes
@Riverpod(keepAlive: true)
Future<ApiClient> baseApiClient(Ref ref) async {
  final basePath = await ref.watch(connectionUrlProvider.future);
  final rootClient = _createHttpClient();
  final extendedClient = ExtendedApiClient(basePath: basePath);
  extendedClient.client = PlatformClient(innerClient: rootClient);
  return extendedClient;
}

/// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]
@Riverpod(keepAlive: true)
Future<ApiClient> baseAuthenticatedClient(Ref ref) async {
  final basePath = await ref.watch(connectionUrlProvider.future);
  final tokens = ref.watch(authTokensProvider).value;
  final rootClient = _createHttpClient();
  final platform = PlatformClient(innerClient: rootClient);
  final interceptor = AuthInterceptorClient(innerClient: platform, ref: ref);

  // Create the AutoLogout wrapper
  final autoLogoutClient = AutoLogoutClient(
    innerClient: interceptor,
    onLogout: () async {
      final auth = ref.read(authProvider.notifier);
      final notifications = ref.read(notificationsProvider.notifier);
      final authState = ref.read(authProvider);

      if (authState.value != null) {
        notifications.openFrontendOnly("Session Expired", type: NotificationTypeEnum.warning, duration: 7);
        await auth.logout();
      }
    },
  );

  final auth = HttpBearerAuth();
  if (tokens?.idToken != null && tokens!.idToken!.isNotEmpty) {
    auth.accessToken = tokens.idToken!;
  }

  // Create the ExtendedApiClient and inject the client stack
  final extendedClient = ExtendedApiClient(basePath: basePath, authentication: auth);
  extendedClient.client = autoLogoutClient;
  return extendedClient;
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

/// Extended API client that allows customization of the base path and auth
class ExtendedApiClient extends ApiClient {
  String _basePath;

  ExtendedApiClient({required super.basePath, super.authentication}) : _basePath = basePath;

  @override
  String get basePath => _basePath;

  set basePath(String newPath) {
    _basePath = newPath;
  }
}
