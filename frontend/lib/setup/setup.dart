import 'package:flutter/material.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/setup/widgets/pages/account.dart';
import 'package:sprout/setup/widgets/pages/complete.dart';
import 'package:sprout/setup/widgets/pages/config.dart';
import 'package:sprout/setup/widgets/pages/welcome.dart';

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
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigates to the next page in the setup flow.
  void _nextPage() {
    final configProvider = ServiceLocator.get<ConfigProvider>();
    if (_currentPageIndex < _totalPages - 1) {
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
        child: SizedBox(
          width: mediaQuery.width * (mediaQuery.width > AppTheme.maxDesktopSize ? .6 : .8),
          height: mediaQuery.height,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swiping
            children: [
              // Step 1: Welcome Page
              WelcomeSetupPage(_nextPage, isDesktop),
              // Step 2: User Creation Page
              AccountSetupPage(_nextPage, isDesktop),
              // Step 3: User Creation Page
              UserConfigSetupPage(_nextPage, isDesktop),
              // Step 4: Complete Page
              CompleteSetupPage(widget.onSetupSuccess, isDesktop),
            ],
          ),
        ),
      );
    });
  }
}
