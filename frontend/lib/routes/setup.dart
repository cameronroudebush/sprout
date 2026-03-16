import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/setup/widgets/pages/account.dart';
import 'package:sprout/setup/widgets/pages/complete.dart';
import 'package:sprout/setup/widgets/pages/config.dart';
import 'package:sprout/setup/widgets/pages/welcome.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// This page contains the process for when the application is first started
class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
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
    final config = ref.read(unsecureConfigProvider.notifier);
    if (_currentPageIndex < _totalPages - 1) {
      // If we're going to the username/password step and this is OIDC mode, ignore the page and skip it
      if (_currentPageIndex == 0 && config.isOIDCAuthMode) {
        // Create the OIDC user and login
        AccountSetupPage.createAccountAndLogin(
          ref: ref,
          onStatusChanged: (message, {isError = false}) {
            if (isError) LoggerProvider.error(message);
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
          height: mediaQuery.height,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Step 1: Welcome Page
              WelcomeSetupPage(_nextPage, isDesktop),
              // Step 2: User Creation Page
              AccountSetupPage(_nextPage, isDesktop),
              // Step 3: User Creation Page
              UserConfigSetupPage(_nextPage, isDesktop),
              // Step 4: Complete Page
              CompleteSetupPage(() => ref.read(authProvider.notifier).completeSetup(), isDesktop),
            ],
          ),
        ),
      );
    });
  }
}
