import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/auto_logout_client.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';

/// Applies the default API content considering the connection URL and the authentication strategy
Future<void> applyDefaultAPI() async {
  final connectionUrl = await ConfigProvider.getConnUrl();
  ConfigProvider.connectionUrl = connectionUrl;
  // Create an extended ApiClient that allows changing the base path
  defaultApiClient = ExtendedApiClient(basePath: connectionUrl, authentication: HttpBearerAuth());
  // Inject a client that automatically logs us out if we start experiencing 401/403's
  final autoLogoutClient = AutoLogoutClient(
    onLogout: () async {
      final authProvider = ServiceLocator.get<AuthProvider>();
      if (authProvider.isLoggedIn) {
        await authProvider.logout(forced: true);
        SnackbarProvider.openSnackbar("Session expired", type: SnackbarType.warning);
      }
    },
  );
  (defaultApiClient as ExtendedApiClient).client = autoLogoutClient;
}

/// An extended ApiClient that allows for changing the base path dynamically.
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
