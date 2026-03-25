import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/setup/setup_provider.dart';
import 'package:sprout/setup/widgets/pages/account.dart';
import 'package:sprout/setup/widgets/pages/complete.dart';
import 'package:sprout/setup/widgets/pages/config.dart';
import 'package:sprout/setup/widgets/pages/welcome.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// This page contains the process for when the application is first started
class SetupPage extends ConsumerWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context).size;
    final currentIndex = ref.watch(setupStepProvider);

    // Initialize the controller with the current index from the provider
    final pageController = PageController(initialPage: currentIndex);

    /// Navigates to the next page in the flow
    void nextPage() {
      final config = ref.read(unsecureConfigProvider.notifier);

      if (currentIndex == 0 && config.isOIDCAuthMode) {
        AccountSetupPage.createAccountAndLogin(
          ref: ref,
          onStatusChanged: (message, {isError = false}) {
            if (isError) LoggerProvider.error(message);
          },
          onSuccess: () {
            ref.read(setupStepProvider.notifier).setStep(2);
          },
        );
      } else {
        ref.read(setupStepProvider.notifier).next();
      }
    }

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Center(
        child: SizedBox(
          height: mediaQuery.height,
          child: PageView(
            key: ValueKey("setup_page_$currentIndex"),
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Step 1: Welcome Page
              WelcomeSetupPage(nextPage, isDesktop),
              // Step 2: User Creation Page
              AccountSetupPage(nextPage, isDesktop),
              // Step 3: User Config Page
              UserConfigSetupPage(nextPage, isDesktop),
              // Step 4: Complete Page
              CompleteSetupPage(() => ref.read(authProvider.notifier).completeSetup(), isDesktop),
            ],
          ),
        ),
      );
    });
  }
}
