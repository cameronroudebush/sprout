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
    final authState = await ref.read(authProvider.future);

    // Check the config to see if we are in OIDC mode
    final config = ref.read(unsecureConfigProvider).value;
    final isOIDC = config?.authMode == UnsecureAppConfigurationAuthModeEnum.oidc;

    // If no user was restored and we are OIDC, fire the login flow
    if (authState == null && isOIDC) {
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
    final isOIDC = ref.read(unsecureConfigProvider.notifier).isOIDCAuthMode;

    try {
      final user = isOIDC
          ? await authNotifier.loginOIDC(manualLogin: true)
          : await authNotifier.login(_usernameController.text.trim(), _passwordController.text.trim());

      if (user == null) {
        setState(() => _errorMessage = failedLoginMessage);
      }
    } catch (e) {
      final msg = ref.read(notificationsProvider.notifier).parseOpenAPIException(e);
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isActionRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configState = ref.watch(unsecureConfigProvider);
    final authState = ref.watch(authProvider);

    // If Auth is currently performing the initial background check
    final isInitializing = authState.isLoading && !authState.hasValue;

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return SizedBox(
        width: 480,
        child: Column(
          spacing: 12,
          children: [
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
                            ),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => _handleLogin(),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: 240,
                      child: FilledButton(
                        style: ThemeHelpers.primaryButton,
                        onPressed: (_isActionRunning || isInitializing) ? null : _handleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 12,
                          children: [
                            if (_isActionRunning || isInitializing)
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3)),
                            Text(
                              isInitializing
                                  ? "Checking Session..."
                                  : isOIDC
                                      ? "Login"
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
