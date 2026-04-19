import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/cookie_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

part 'bg_job_provider.g.dart';

@riverpod
bool isBackgroundJob(Ref ref) => false;

/// This class provides assistance with background jobs
class BackgroundJobProvider {
  /// A reusable entry point for background isolates to ensure the following:
  /// 1. Authentication state is fully resolved and OIDC tokens are refreshed as needed.
  /// 2. We tell the [isBackgroundJob] provider that we are running as a background.
  /// 3. Returns the providers to use.
  static Future<(ProviderContainer, User?)> entry(String jobName) async {
    LoggerProvider.debug("Starting background task for $jobName");
    WidgetsFlutterBinding.ensureInitialized();
    // Manually manage a ProviderContainer for the background isolate
    final container = ProviderContainer(
      overrides: [
        // Force the provider to true for this container instance
        isBackgroundJobProvider.overrideWithValue(true),
      ],
    );
    User? user;
    try {
      // Force the cookie jar to initialize with persistence
      await container.read(cookieJarProvider(true).future);
      // Attempt to resolve the Auth Provider
      user = await container.read(authProvider.future);
    } catch (e) {
      LoggerProvider.error("Failed to resolve the user: $e");
    }

    return (container, user);
  }
}
