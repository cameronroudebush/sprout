import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/user/user_config_provider.dart';

/// The form used within the login page that separates the login inputs from the overall rendering
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  static const failedLoginMessage = "Login failed. Please check credentials.";

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isActionRunning = false;

  @override
  void initState() {
    super.initState();
    _errorMessage = "";
    Future.microtask(() => _autoLogin());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// This function attempts to automatically login, if we don't have a current user
  Future<void> _autoLogin() async {
    final auth = ref.read(authProvider.notifier);
    final authState = await ref.read(authProvider.future);

    // Check the config to see if we are in OIDC mode
    final config = ref.read(unsecureConfigProvider).value;
    final isOIDC = config?.authMode == UnsecureAppConfigurationAuthModeEnum.oidc;

    // If no user was restored and we are OIDC, fire the login flow
    if (authState == null && !auth.isLoggingOut && isOIDC) {
      LoggerProvider.debug("No session restored, initiating OIDC auto-login.");
      await _handleLogin();
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isActionRunning = true;
      _errorMessage = '';
    });

    final authNotifier = ref.read(authProvider.notifier);
    if (authNotifier.isSetupMode) return; // Ignore login requests if we're moving to setup mode.
    final isOIDC = ref.read(unsecureConfigProvider.notifier).isOIDCAuthMode;

    try {
      final user = isOIDC
          ? await authNotifier.loginOIDC(manualLogin: true)
          : await authNotifier.login(_usernameController.text.trim(), _passwordController.text.trim());

      if (user == null) {
        setState(() {
          _errorMessage = failedLoginMessage;
          _isActionRunning = false;
        });
      } else {
        ref.invalidate(secureConfigProvider);
        ref.invalidate(userConfigProvider);
      }
    } catch (e) {
      final msg = ref.read(notificationsProvider.notifier).parseOpenAPIException(e);
      setState(() {
        _errorMessage = msg;
        _isActionRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configState = ref.watch(unsecureConfigProvider);
    final config = ref.watch(unsecureConfigProvider).value;
    final isDemoMode = ref.watch(unsecureConfigProvider.notifier).isDemoMode();

    // Watch auth and post-login configurations to sync with the router's loading state
    final authState = ref.watch(authProvider);
    final secureConfigState = ref.watch(secureConfigProvider);
    final userConfigState = ref.watch(userConfigProvider);

    if (isDemoMode) {
      _usernameController.text = config!.demoMode!.username;
      _passwordController.text = config.demoMode!.password;
    }

    // Determine all our possible loading states
    final isInitializing = authState.isLoading && !authState.hasValue;
    final isConfigLoading = authState.value != null && (secureConfigState.isLoading || userConfigState.isLoading);
    final isBusy = _isActionRunning || isInitializing || isConfigLoading;

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return SizedBox(
        width: 480,
        child: Column(
          spacing: 12,
          children: [
            if (isDemoMode && !kDebugMode)
              SproutNotificationWidget(
                SproutNotification(
                  "Demo mode is enabled. Please login below.",
                  theme.colorScheme.primary,
                  theme.colorScheme.onPrimary,
                ),
              ),
            if (_errorMessage.isNotEmpty)
              SproutNotificationWidget(
                SproutNotification(_errorMessage, theme.colorScheme.error, theme.colorScheme.onError),
              ),

            // Render loading or form
            configState.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Configuration Error: $err'),
              data: (config) {
                final isOIDC = config?.authMode == UnsecureAppConfigurationAuthModeEnum.oidc;

                return Column(
                  spacing: 12,
                  children: [
                    if (!isOIDC)
                      AutofillGroup(
                        child: Column(
                          spacing: 12,
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
                              autofillHints: const [AutofillHints.username],
                              enabled: !isDemoMode && !isBusy, // Optional: disable inputs while loading
                            ),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) {
                                if (!isBusy) _handleLogin();
                              },
                              enabled: !isDemoMode && !isBusy,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: 240,
                      child: FilledButton(
                        style: ThemeHelpers.primaryButton,
                        onPressed: isBusy ? null : _handleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 12,
                          children: [
                            if (isBusy)
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3)),
                            Text(
                              isInitializing
                                  ? "Checking Session..."
                                  : isConfigLoading
                                      ? "Loading Workspace..."
                                      : "Login",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
