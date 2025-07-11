// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/user.dart';
import 'package:sprout/home.dart';
import 'package:sprout/widgets/button.dart';

/// A stateful widget for the login page.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
    if (_usernameController.text == "" || _passwordController.text == "") {
      return;
    }

    final success = await Provider.of<UserAPI>(
      context,
      listen: false,
    ).loginWithPassword(_usernameController.text, _passwordController.text);

    if (success) {
      // Navigate to the ProfilePage on successful login, replacing the current route.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _message = 'Login failed. Please check credentials.';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkJWTLogin();
  }

  /// Checks if we can login with the JWT and if so moves on to the next page.
  Future<void> _checkJWTLogin() async {
    final configAPI = Provider.of<UserAPI>(context, listen: false);
    bool successLogin = await configAPI.loginWithJWT(null);
    if (successLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * .025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 640),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextField(
                            controller: _passwordController,
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
                  const SizedBox(height: 30.0),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 640),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: ButtonWidget(
                        text: "Login",
                        onPressed:
                            _passwordController.text == "" ||
                                _usernameController.text == ""
                            ? null
                            : _login,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    _message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
