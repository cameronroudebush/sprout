import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

extension AuthBackgroundTrigger on Auth {
  /// A reusable entry point for background isolates to ensure
  /// the authentication state is fully resolved.
  static Future<User?> ensureAuthenticated(ProviderContainer container) async {
    try {
      // Force the cookie jar to initialize with persistence
      await container.read(cookieJarProvider(true).future);
      // Attempt to resolve the Auth Provider
      var user = await container.read(authProvider.future);
      if (user == null) throw Exception("Failed to locate user");
      return user;
    } catch (e) {
      LoggerProvider.error("Background Auth: Critical failure during resolution: $e");
      return null;
    }
  }
}
