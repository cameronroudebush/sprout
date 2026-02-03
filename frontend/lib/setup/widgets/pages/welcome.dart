import 'package:flutter/material.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';

/// This page contains the initial page welcoming the user to the app
class WelcomeSetupPage extends StatelessWidget {
  final VoidCallback nextPage;
  final bool isDesktop;
  const WelcomeSetupPage(this.nextPage, this.isDesktop, {super.key});

  @override
  Widget build(BuildContext context) {
    return SetupPageWrapper(
      isDesktop,
      "Get Started",
      nextPage,
      Column(
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
        ],
      ),
    );
  }
}
