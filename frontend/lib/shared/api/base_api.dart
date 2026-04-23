import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/cookie_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/api/auto_logout_client.dart';
import 'package:sprout/shared/api/base_path_client.dart';
import 'package:sprout/shared/api/browser_client.dart' if (dart.library.html) 'package:http/browser_client.dart';
import 'package:sprout/shared/api/cookie_client.dart';
import 'package:sprout/shared/api/header_client.dart';
import 'package:sprout/shared/api/timeout_client.dart';
import 'package:sprout/shared/providers/bg_job_provider.dart';

part 'base_api.g.dart';

/// Root client to use with every other client
@Riverpod(keepAlive: true)
Future<http.Client> rootHttpClient(Ref ref) async {
  final jar = await ref.watch(cookieJarProvider(true).future);

  http.Client client;
  if (kIsWeb) {
    client = BrowserClient()..withCredentials = true;
  } else {
    // Mobile uses our custom CookieClient
    client = CookieClient(innerClient: http.Client(), cookieJar: jar);
  }

  return RetryClient(
    client,
    retries: 2,
    when: (response) => response.statusCode >= 500 && response.statusCode <= 599,
  );
}

/// Base API client that only adds the connection URL. Everything else is basic and this should be used for public routes
@Riverpod(keepAlive: true)
Future<ApiClient> baseApiClient(Ref ref) async {
  final basePath = await ref.watch(connectionUrlProvider.future);
  final rootClient = await ref.watch(rootHttpClientProvider.future);
  final platformClient = HeaderClient(innerClient: rootClient);
  final timeoutClient = TimeoutClient(innerClient: platformClient, timeout: 5);
  return BasePathClient(client: timeoutClient, basePath: basePath ?? "");
}

/// Base API client that implements things auto logout, auth info, and auto retries on top of [baseApiClient]
@Riverpod(keepAlive: true)
Future<ApiClient> baseAuthenticatedClient(Ref ref) async {
  final basePath = await ref.watch(connectionUrlProvider.future);
  final rootClient = await ref.watch(rootHttpClientProvider.future);
  final platformClient = HeaderClient(innerClient: rootClient);

  // Create the AutoLogout wrapper
  final autoLogoutClient = AutoLogoutClient(
    innerClient: platformClient,
    onLogout: () async {
      // Don't do anything if we're a background job
      if (ref.read(isBackgroundJobProvider)) return;

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

  return BasePathClient(client: autoLogoutClient, basePath: basePath ?? "");
}
