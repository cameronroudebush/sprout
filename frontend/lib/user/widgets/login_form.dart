import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/provider/auth.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/notification.dart';

/// A widget that is used to display the login form to allow the user to authenticate with username/password
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const failedLoginMessage = "Login failed. Please check credentials.";

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Message to display login status or errors.
  String _message = '';
  bool _loginIsRunning = false;
  bool _isLoadingData = false;

  /// Fires after our login is complete
  Future<void> _loginComplete(User? user, {String failureMessage = _LoginFormState.failedLoginMessage}) async {
    if (user != null) {
      _usernameController.clear();
      _passwordController.clear();
      setState(() {
        _loginIsRunning = false;
        _isLoadingData = true;
      });
      // Request our basic data
      await ServiceLocator.postLogin();
      setState(() {
        _isLoadingData = false;
      });
      // After login, check if we were sent from a specific page.
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      // If 'from' exists, go there. Otherwise, go to the home page.
      GoRouter.of(context).go(from ?? '/');
    } else {
      setState(() {
        _loginIsRunning = false;
        _message = failureMessage;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    // Attempt initial login
    final authProvider = ServiceLocator.get<AuthProvider>();
    setState(() {
      _loginIsRunning = false;
    });
    authProvider
        .tryInitialLogin()
        .then((user) async {
          await _loginComplete(user, failureMessage: user == null ? "" : _LoginFormState.failedLoginMessage);
        })
        .onError((ApiException error, StackTrace stackTrace) async {
          final isSessionExpiration = error.code == 401;
          // Reset the JWT as the auto login has expired
          if (isSessionExpiration) {
            // TODO
            await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, null);
          }
          await _loginComplete(null, failureMessage: isSessionExpiration ? error.message ?? 'Session Expired' : "");
        });
  }

  /// Forces a rerender
  void _updateButtonState() {
    setState(() {});
  }

  /// Handles the login process when the login button is pressed.
  Future<void> _login() async {
    final authProvider = ServiceLocator.get<AuthProvider>();
    final configProvider = ServiceLocator.get<ConfigProvider>();

    if (configProvider.unsecureConfig?.oidcConfig != null) {
      // OIDC login
      await authProvider.loginOIDC();
    } else {
      TextInput.finishAutofillContext();
      if (_usernameController.text == "" || _passwordController.text == "") {
        return;
      }
      User? user;
      try {
        setState(() {
          _loginIsRunning = true;
        });
        user = await authProvider.login(_usernameController.text.trim(), _passwordController.text.trim());
        // Successful login? Request data and go home
        await _loginComplete(user);
      } finally {
        if (user == null) {
          setState(() {
            _message = _LoginFormState.failedLoginMessage;
            _loginIsRunning = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Consumer<ConfigProvider>(
        builder: (context, provider, child) {
          return SizedBox(
            width: 480,
            child: Column(
              spacing: 12,
              children: [
                if (_message.isNotEmpty)
                  SproutNotificationWidget(
                    SproutNotification(_message, theme.colorScheme.error, theme.colorScheme.onError),
                  ),
                if (provider.unsecureConfig?.oidcConfig == null)
                  AutofillGroup(
                    child: Column(
                      spacing: 12,
                      children: [
                        TextField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          autofillHints: const [AutofillHints.username],
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
                        ),
                        TextField(
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (String value) {
                            _login();
                          },
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: 240,
                  child: FilledButton(
                    style: AppTheme.primaryButton,
                    onPressed: provider.unsecureConfig?.oidcConfig != null
                        ? _login
                        : (_passwordController.text == "" || _usernameController.text == "" || _loginIsRunning)
                        ? null
                        : _login,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 12,
                      children: [
                        if (_loginIsRunning || _isLoadingData)
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3)),
                        Text(
                          _isLoadingData
                              ? "Loading Data"
                              : provider.unsecureConfig?.oidcConfig == null
                              ? "Login"
                              : "Login with OIDC",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
