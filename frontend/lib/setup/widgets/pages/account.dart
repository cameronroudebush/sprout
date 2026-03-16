import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/user/user_provider.dart';

/// This page contains the process and inputs for creating a new user account
class AccountSetupPage extends ConsumerStatefulWidget {
  final VoidCallback nextPage;
  final bool isDesktop;
  const AccountSetupPage(this.nextPage, this.isDesktop, {super.key});

  /// Uses riverpod to create the account and login
  static Future<void> createAccountAndLogin({
    required WidgetRef ref,
    String? username,
    String? password,
    Function(String message, {bool isError})? onStatusChanged,
    VoidCallback? onSuccess,
  }) async {
    final unsecureConfig = ref.read(unsecureConfigProvider).value;
    final isOIDC = unsecureConfig?.authMode == UnsecureAppConfigurationAuthModeEnum.oidc;

    // Validation Guard for non OIDC
    if (!isOIDC && ((username ?? '').isEmpty || (password ?? '').isEmpty)) {
      onStatusChanged?.call('Username/password cannot be empty.', isError: true);
      return;
    }

    try {
      final userApi = await ref.read(userApiProvider.future);
      final registered = await userApi.userControllerCreate(
        UserCreationRequest(username: username ?? '', password: password ?? ''),
      );

      if (registered == null) {
        onStatusChanged?.call('Failed to create account. Username might be taken.', isError: true);
        return;
      }

      onStatusChanged?.call('Account created! Logging in...', isError: false);

      final authNotifier = ref.read(authProvider.notifier);

      // Attempt Login
      final loggedIn = await (isOIDC ? authNotifier.loginOIDC() : authNotifier.login(username!, password!));

      if (loggedIn == null) {
        onStatusChanged?.call('Account created but failed to get user.', isError: true);
        return;
      }

      onStatusChanged?.call('Login successful!', isError: false);
      onSuccess?.call();
    } catch (e) {
      final errorMsg = ref.read(notificationsProvider.notifier).parseOpenAPIException(e);
      onStatusChanged?.call(errorMsg, isError: true);
    }
  }

  @override
  ConsumerState<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends ConsumerState<AccountSetupPage> {
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

  Future<void> _handleCreateAccount() async {
    setState(() {
      _isLoading = true;
      _message = 'Creating account...';
      _isFailureMessage = false;
    });

    await AccountSetupPage.createAccountAndLogin(
      ref: ref,
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      onStatusChanged: (msg, {isError = false}) {
        if (mounted) {
          setState(() {
            _message = msg;
            _isFailureMessage = isError;
            if (isError) _isLoading = false;
          });
        }
      },
      onSuccess: () {
        if (mounted) {
          setState(() => _isLoading = false);
          widget.nextPage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Disable button if loading or fields empty
    final bool canSubmit = !_isLoading && _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    return SetupPageWrapper(
      widget.isDesktop,
      "Create Account",
      canSubmit ? _handleCreateAccount : null,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: <Widget>[
          Text(
            'Create Your Admin Account',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.isDesktop ? 64 : 24),
          ),
          Text(
            'This will be your primary account to manage Sprout.',
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
              allowMultiLine: true,
            ),

          AutofillGroup(
            child: Column(
              spacing: 16,
              children: [
                TextField(
                  controller: _usernameController,
                  autofillHints: [AutofillHints.newUsername],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Choose Username', prefixIcon: Icon(Icons.person_add)),
                ),
                TextField(
                  controller: _passwordController,
                  autofillHints: [AutofillHints.newPassword],
                  onChanged: (_) => setState(() {}),
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Choose Password', prefixIcon: Icon(Icons.lock_open)),
                  onSubmitted: (_) => canSubmit ? _handleCreateAccount() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
