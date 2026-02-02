import 'package:flutter/material.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/setup/widgets/account_page.dart';

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
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigates to the next page in the setup flow.
  void _nextPage() {
    final configProvider = ServiceLocator.get<ConfigProvider>();
    if (_currentPageIndex < 2) {
      // Assuming 3 pages (0, 1, 2)
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

      // If we're going to the username/password step and this is OIDC mode, ignore the page and skip it
      if (_currentPageIndex == 0 && configProvider.isOIDCAuthMode) {
        // Create the OIDC user and login
        AccountSetupPage.createAccountAndLogin(
          onStatusChanged: (message, {isError = false}) {
            if (isError) LoggerService.error(message);
          },
          onSuccess: () {
            setState(() {
              _currentPageIndex = _currentPageIndex + 2;
            });
            _pageController.jumpToPage(_currentPageIndex);
          },
        );
      } else {
        setState(() {
          _currentPageIndex++;
        });
      }
      _pageController.jumpToPage(_currentPageIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              // Step 1: Welcome Page
              _buildWelcomePage(isDesktop),
              // Step 2: Admin User Creation Page
              AccountSetupPage(onNextPage: _nextPage),
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
              'Your account has been successfully created. You\'re all set to explore the app!',
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
