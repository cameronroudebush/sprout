import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_interceptor.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/auto_logout_client.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';

/// Applies the default API content considering the connection URL and the authentication strategy
Future<void> applyDefaultAPI() async {
  final connectionUrl = await ConfigProvider.getConnUrl();
  ConfigProvider.connectionUrl = connectionUrl;

  // Create the ExtendedApiClient
  final extendedClient = ExtendedApiClient(basePath: connectionUrl, authentication: HttpBearerAuth());

  // Create the inner interceptor that handles refreshing OIDC if required
  final interceptor = AuthInterceptor();

  // Create the outer interceptor so we can configure to auto logout if the refresh doesn't fix our 401/403 issues
  final autoLogoutClient = AutoLogoutClient(
    innerClient: interceptor,
    onLogout: () async {
      final authProvider = ServiceLocator.get<AuthProvider>();
      if (authProvider.isLoggedIn) {
        await authProvider.logout(forced: true);
        SnackbarProvider.openSnackbar("Session expired", type: SnackbarType.warning);
      }
    },
  );

  // Use the setter to inject the entire stack into the ApiClient
  extendedClient.client = autoLogoutClient;

  // Assign to the global client reference
  defaultApiClient = extendedClient;
}

class ExtendedApiClient extends ApiClient {
  String _basePath;

  ExtendedApiClient({required super.basePath, super.authentication}) : _basePath = basePath;

  @override
  String get basePath => _basePath;

  /// Updates the base path for all future API calls.
  set basePath(String newPath) {
    _basePath = newPath;
  }
}
