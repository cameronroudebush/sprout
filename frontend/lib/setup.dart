// lib/pages/setup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/setup.dart';
import 'package:sprout/api/user.dart';
import 'package:sprout/login.dart';
import 'package:sprout/widgets/app_bar.dart';
import 'package:sprout/widgets/button.dart';
import 'package:sprout/widgets/text.dart';

/// This page contains the process for when the application is first started
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // Controller for the PageView to manage page transitions.
  final PageController _pageController = PageController();
  // Current step in the setup process.
  int _currentPageIndex = 0;

  // Controllers for username and password input fields, now managed by the state.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  /// Navigates to the next page in the setup flow.
  void _nextPage() {
    if (_currentPageIndex < 2) {
      // Assuming 3 pages (0, 1, 2)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPageIndex++;
      });
    }
  }

  /// Handles the account creation and login process.
  Future<void> _createAccountAndLogin() async {
    TextInput.finishAutofillContext();
    setState(() {
      _isLoading = true;
      _message = 'Creating account...';
    });

    final setupAPI = Provider.of<SetupAPI>(context, listen: false);
    final userAPI = Provider.of<UserAPI>(context, listen: false);
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Username and password cannot be empty.';
        _isLoading = false;
      });
      return;
    }

    // First, attempt to register the new user
    final registered = await setupAPI.createUser(username, password);

    if (registered) {
      setState(() {
        _message = 'Account created successfully! Logging in...';
      });
      // If registration is successful, automatically log in the user
      final loggedIn = await userAPI.loginWithPassword(username, password);

      if (loggedIn) {
        setState(() {
          _message = 'Login successful!';
          _isLoading = false;
        });
        _nextPage(); // Move to the "Complete" page
      } else {
        setState(() {
          _message =
              'Account created but failed to log in. Please try logging in manually.';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _message =
            'Failed to create account. Username might be taken or server error.';
        _isLoading = false;
      });
    }
  }

  /// Navigates to the main application (ProfilePage) after setup is complete.
  void _finishSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SproutAppBar(
        toolbarHeight: MediaQuery.of(context).size.height * .075,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width *
                (MediaQuery.of(context).size.width > 1024 ? .6 : .8),
          ),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swiping
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: [
              // Step 1: Welcome Page
              _buildWelcomePage(),
              // Step 2: Admin User Creation Page
              _buildAdminUserCreationPage(),
              // Step 3: Complete Page
              _buildCompletePage(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Welcome page of the setup flow.
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextWidget(
            referenceSize: 4,
            text: 'Welcome to Sprout!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          TextWidget(
            referenceSize: 1.5,
            text:
                "Get ready to take control of your financial future. Sprout is your personal, self-hostable finance tracker designed to give you a crystal-clear view of your net worth, account balances, and transaction history over time. Let's get started on setting up your financial journey.",
          ),
          const SizedBox(height: 60.0),
          ButtonWidget(text: "Get Started", onPressed: _nextPage),
        ],
      ),
    );
  }

  /// Builds the Admin User Creation page of the setup flow.
  Widget _buildAdminUserCreationPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextWidget(
            referenceSize: 3,
            text: 'Create Your Admin Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          TextWidget(
            referenceSize: 1.25,
            text:
                'This will be your primary account to manage the app. Please choose a secure username and password.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40.0),
          AutofillGroup(
            child: TextField(
              controller: _usernameController,
              autofillHints: [AutofillHints.newUsername],
              decoration: const InputDecoration(
                labelText: 'Choose Username',
                prefixIcon: Icon(Icons.person_add),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _passwordController,
            autofillHints: [AutofillHints.newPassword],
            decoration: const InputDecoration(
              labelText: 'Choose Password',
              prefixIcon: Icon(Icons.lock_open),
            ),
            onSubmitted: (String value) {
              _createAccountAndLogin();
            },
            obscureText: true,
          ),
          const SizedBox(height: 30.0),
          _isLoading
              ? const CircularProgressIndicator()
              : ButtonWidget(
                  text: "Create Account",
                  onPressed:
                      _passwordController.text == "" ||
                          _usernameController.text == ""
                      ? null
                      : _createAccountAndLogin,
                ),
          const SizedBox(height: 20.0),
          Text(
            _message,
            style: TextStyle(
              color: _message.contains('Failed')
                  ? Colors.red[700]
                  : Colors.green[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the Complete page of the setup flow.
  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: MediaQuery.of(context).size.height * .25,
          ),
          const SizedBox(height: 20.0),
          TextWidget(
            referenceSize: 3,
            text: 'Setup Complete!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          TextWidget(
            referenceSize: 1.25,
            text:
                'Your admin account has been successfully created. You\'re all set to explore the app!',
          ),
          const SizedBox(height: 60.0),
          ButtonWidget(text: "Go to App", onPressed: _finishSetup),
        ],
      ),
    );
  }
}
