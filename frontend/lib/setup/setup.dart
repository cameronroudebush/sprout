import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/provider/auth.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/notification.dart';
import 'package:sprout/user/user_provider.dart';

/// This page contains the process for when the application is first started
class SetupPage extends StatefulWidget {
  final VoidCallback onSetupSuccess;
  const SetupPage({super.key, required this.onSetupSuccess});

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
  bool _isFailureMessage = false;
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
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
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
      _isFailureMessage = false;
      _message = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = ServiceLocator.get<AuthProvider>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Username and password cannot be empty.';
        _isLoading = false;
        _isFailureMessage = true;
      });
      return;
    }

    // First, attempt to register the new user
    try {
      final registered = await userProvider.createUser(username, password);
      if (registered != null) {
        setState(() {
          _message = 'Account created successfully! Logging in...';
          _isFailureMessage = false;
        });
        // If registration is successful, automatically log in the user
        final loggedIn = await authProvider.login(username, password);

        if (loggedIn != null) {
          setState(() {
            _message = 'Login successful!';
            _isLoading = false;
            _isFailureMessage = false;
          });
          // Trigger post login state update
          await ServiceLocator.postLogin();
          _nextPage(); // Move to the "Complete" page
        } else {
          setState(() {
            _message = 'Account created but failed to log in. Please try logging in manually.';
            _isLoading = false;
            _isFailureMessage = true;
          });
        }
      } else {
        setState(() {
          _message = 'Failed to create account. Username might be taken or server error.';
          _isLoading = false;
          _isFailureMessage = true;
        });
      }
    } catch (e) {
      setState(() {
        _message = SnackbarProvider.parseOpenAPIException(e);
        _isLoading = false;
        _isFailureMessage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context).size;
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: mediaQuery.width * (mediaQuery.width > AppTheme.maxDesktopSize ? .6 : .8),
            maxHeight: mediaQuery.height * .8,
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
              _buildWelcomePage(isDesktop),
              // Step 2: Admin User Creation Page
              _buildAdminUserCreationPage(theme, isDesktop),
              // Step 3: Complete Page
              _buildCompletePage(isDesktop),
            ],
          ),
        ),
      );
    });
  }

  /// Builds the Welcome page of the setup flow.
  Widget _buildWelcomePage(bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 720 : 360),
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Sprout!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 64 : 36),
              textAlign: TextAlign.center,
            ),
            Text(
              "Get ready to take control of your financial future. Sprout is your personal, self-hostable finance tracker designed to give you a crystal-clear view of your net worth, account balances, and transaction history over time. Let's get started on setting up your financial journey.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isDesktop ? 20 : 16),
            ),
            SizedBox(
              width: 240,
              child: FilledButton(onPressed: _nextPage, child: Text("Get Started")),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Admin User Creation page of the setup flow.
  Widget _buildAdminUserCreationPage(ThemeData theme, bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 720 : 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: <Widget>[
            Text(
              'Create Your Admin Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 48 : 24),
            ),
            Text(
              'This will be your primary account to manage the app. Please choose a secure username and password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isDesktop ? 18 : 14),
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
            FilledButton(
              onPressed: _passwordController.text == "" || _usernameController.text == "" || _isLoading
                  ? null
                  : _createAccountAndLogin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  if (_isLoading) const SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
                  Text("Create Account"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Complete page of the setup flow.
  Widget _buildCompletePage(bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 720 : 360),
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.check_circle_outline, color: Colors.green, size: MediaQuery.of(context).size.height * .25),
            Text(
              'Setup Complete!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 48 : 36),
            ),
            Text(
              'Your admin account has been successfully created. You\'re all set to explore the app!',
              style: TextStyle(fontSize: isDesktop ? 24 : 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 256,
              child: FilledButton(onPressed: widget.onSetupSuccess, child: Text("Go to Sprout")),
            ),
          ],
        ),
      ),
    );
  }
}
