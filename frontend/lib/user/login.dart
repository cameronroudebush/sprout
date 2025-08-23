// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/model/user.dart';

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

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  /// Forces a rerender
  void _updateButtonState() {
    setState(() {});
  }

  /// Handles the login process when the login button is pressed.
  Future<void> _login() async {
    TextInput.finishAutofillContext();
    if (_usernameController.text == "" || _passwordController.text == "") {
      return;
    }
    User? user;
    try {
      user = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(_usernameController.text.trim(), _passwordController.text.trim());
    } finally {
      if (user == null) {
        setState(() {
          _message = 'Login failed. Please check credentials.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        return SproutScaffold(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                          text: 'Welcome Back!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 640),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .7,
                          child: AutofillGroup(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _usernameController,
                                  keyboardType: TextInputType.text,
                                  autofillHints: const [AutofillHints.username],
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                TextField(
                                  controller: _passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  autofillHints: const [AutofillHints.password],
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (String value) {
                                    _login();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 640),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: ButtonWidget(
                            text: "Login",
                            onPressed: _passwordController.text == "" || _usernameController.text == "" ? null : _login,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextWidget(
                        referenceSize: 1.2,
                        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                        text: _message,
                      ),
                      const SizedBox(height: 20.0),
                      TextWidget(referenceSize: .9, text: configProvider.unsecureConfig?.version ?? ""),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
