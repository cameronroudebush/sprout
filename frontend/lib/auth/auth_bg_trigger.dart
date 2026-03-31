import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/auth_token_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

extension AuthBackgroundTrigger on Auth {
  /// A reusable entry point for background isolates to ensure
  /// the authentication state is fully resolved.
  static Future<User?> ensureAuthenticated(ProviderContainer container) async {
    try {
      // Force the Token Storage to load into memory
      final tokens = await container.read(authTokensProvider.future);

      if (tokens.idToken == null || tokens.idToken == "") {
        LoggerProvider.debug("Background Auth: No tokens found in storage.");
        return null;
      }

      // Attempt to resolve the Auth Provider
      var user = await container.read(authProvider.future);

      // If the User is null or the check failed, attempt a Silent Refresh
      if (user == null) {
        LoggerProvider.debug("Background Auth: ID Token likely expired. Attempting refresh...");
        final success = await container.read(authProvider.notifier).silentRefresh();

        if (success) {
          // Re-read the authProvider to get the newly refreshed User
          user = await container.read(authProvider.future);
          LoggerProvider.debug("Background Auth: Refresh successful.");
        } else {
          LoggerProvider.error("Background Auth: Refresh failed.");
        }
      }

      return user;
    } catch (e) {
      LoggerProvider.error("Background Auth: Critical failure during resolution: $e");
      return null;
    }
  }
}
