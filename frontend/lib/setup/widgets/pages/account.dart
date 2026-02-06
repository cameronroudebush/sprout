import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/notification.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';

/// This page contains the process and inputs for creating a new user account
class AccountSetupPage extends StatefulWidget {
  final VoidCallback nextPage;
  final bool isDesktop;
  const AccountSetupPage(this.nextPage, this.isDesktop, {super.key});

  /// Creates the account and logs in as the created user
  static Future<void> createAccountAndLogin({
    String? username,
    String? password,
    Function(String message, {bool isError})? onStatusChanged,
    VoidCallback? onSuccess,
  }) async {
    final configProvider = SproutProviders.config;
    final userProvider = SproutProviders.user;
    // Validation Guard for non OIDC
    if (!configProvider.isOIDCAuthMode && ((username ?? '').isEmpty || (password ?? '').isEmpty)) {
      onStatusChanged?.call('Username/password cannot be empty.', isError: true);
      return;
    }

    try {
      // Attempt Registration
      final registered = await userProvider.api.userControllerCreate(
        UserCreationRequest(username: username ?? '', password: password ?? ''),
      );

      if (registered == null) {
        onStatusChanged?.call('Failed to create account. Username might be taken.', isError: true);
        return;
      }

      // Update Status & Attempt Login
      onStatusChanged?.call('Account created! Logging in...', isError: false);

      final authProvider = SproutProviders.auth;
      final loggedIn = await (configProvider.isOIDCAuthMode
          ? authProvider.tryInitialLogin()
          : authProvider.login(username!, password!));

      if (loggedIn == null) {
        onStatusChanged?.call('Account created but failed to get user.', isError: true);
        return;
      }

      await ServiceLocator.postLogin();
      onStatusChanged?.call('Login successful!', isError: false);
      onSuccess?.call();
    } catch (e) {
      onStatusChanged?.call(SproutProviders.notification.parseOpenAPIException(e), isError: true);
    }
  }

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';
  bool _isFailureMessage = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  Future<void> _createAccountAndLogin() async {
    await AccountSetupPage.createAccountAndLogin(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      onStatusChanged: (msg, {isError = false}) {
        setState(() {
          _message = msg;
          _isFailureMessage = isError;
          if (isError) _isLoading = false;
        });
      },
      onSuccess: () {
        setState(() => _isLoading = false);
        widget.nextPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SetupPageWrapper(
      widget.isDesktop,
      "Create Account",
      _passwordController.text == "" || _usernameController.text == "" || _isLoading ? null : _createAccountAndLogin,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: <Widget>[
          Text(
            'Create Your Admin Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.isDesktop ? 64 : 36),
          ),
          Text(
            'This will be your primary account to manage the app. Please choose a secure username and password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: widget.isDesktop ? 18 : 14),
          ),
          if (_message.isNotEmpty)
            SproutNotificationWidget(
              SproutNotification(
                _message,
                _isFailureMessage ? theme.colorScheme.error : theme.colorScheme.secondary,
                _isFailureMessage ? theme.colorScheme.onError : theme.colorScheme.onSecondary,
              ),
            ),
          AutofillGroup(
            child: TextField(
              controller: _usernameController,
              autofillHints: [AutofillHints.newUsername],
              decoration: const InputDecoration(labelText: 'Choose Username', prefixIcon: Icon(Icons.person_add)),
            ),
          ),
          TextField(
            controller: _passwordController,
            autofillHints: [AutofillHints.newPassword],
            decoration: const InputDecoration(labelText: 'Choose Password', prefixIcon: Icon(Icons.lock_open)),
            onSubmitted: (String value) {
              _createAccountAndLogin();
            },
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
