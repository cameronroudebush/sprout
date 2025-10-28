import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/user/user_provider.dart';

/// A stateful widget for the login page.
class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for username and password input fields.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Message to display login status or errors.
  String _message = '';
  bool _loginIsRunning = false;
  bool _isLoadingData = false;

  /// Fires after our login is complete
  Future<void> _loginComplete(User? user, {bool isInitialLogin = false}) async {
    if (user != null) {
      _usernameController.clear();
      _passwordController.clear();
      setState(() {
        _loginIsRunning = false;
        _isLoadingData = true;
      });
      // Request our basic data
      await Future.wait(
        ServiceLocator.getAllProviders().map((provider) async {
          try {
            await provider.postLogin();
          } catch (e) {
            LoggerService.error("Failed to load data for provider ${provider.runtimeType}: $e");
          }
        }),
      );
      setState(() {
        _isLoadingData = false;
      });
      SproutNavigator.redirect("home");
    } else {
      setState(() {
        _loginIsRunning = false;
        _message = !isInitialLogin ? "Login failed. Please check credentials." : "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    // Attempt initial login
    final userProvider = ServiceLocator.get<UserProvider>();
    setState(() {
      _loginIsRunning = true;
    });
    userProvider
        .checkInitialLoginStatus()
        .then((user) async {
          await _loginComplete(user, isInitialLogin: true);
        })
        .onError((Object error, StackTrace stackTrace) async {
          await _loginComplete(null, isInitialLogin: true);
        });
  }

  /// Forces a rerender
  void _updateButtonState() {
    setState(() {});
  }

  /// Handles the login process when the login button is pressed.
  Future<void> _login() async {
    final userProvider = ServiceLocator.get<UserProvider>();
    TextInput.finishAutofillContext();
    if (_usernameController.text == "" || _passwordController.text == "") {
      return;
    }
    User? user;
    try {
      setState(() {
        _loginIsRunning = true;
      });
      user = await userProvider.login(_usernameController.text.trim(), _passwordController.text.trim());
      // Successful login? Request data and go home
      await _loginComplete(user);
    } finally {
      if (user == null) {
        setState(() {
          _message = 'Login failed. Please check credentials.';
          _loginIsRunning = false;
        });
      }
    }
  }

  Widget _buildLoginForm(BuildContext context, ConfigProvider configProvider) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AutofillGroup(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                autofillHints: const [AutofillHints.username],
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 20.0),
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
        const SizedBox(height: 30.0),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .5,
            child: ButtonWidget(
              text: "Login",
              icon: _loginIsRunning ? Icons.hourglass_full : null,
              onPressed: _passwordController.text == "" || _usernameController.text == "" || _loginIsRunning
                  ? null
                  : _login,
            ),
          ),
        ),
        if (_message.isNotEmpty) const SizedBox(height: 20.0),
        if (_message.isNotEmpty)
          TextWidget(
            referenceSize: 1.2,
            style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
            text: _message,
          ),
        const SizedBox(height: 20.0),
        TextWidget(referenceSize: .9, text: configProvider.unsecureConfig?.version ?? ""),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo/color-transparent-no-tag.png',
                      width: MediaQuery.of(context).size.height * .4,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: TextWidget(
                        referenceSize: 2,
                        text: !_isLoadingData ? 'Welcome Back!' : "Getting your data ready...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 640),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .7,
                        child: _isLoadingData
                            ? Center(child: CircularProgressIndicator())
                            : _buildLoginForm(context, configProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
