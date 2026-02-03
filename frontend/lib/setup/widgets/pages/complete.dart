import 'package:flutter/material.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';

/// This page contains the final page that pretty much says welcome!
class CompleteSetupPage extends StatelessWidget {
  final VoidCallback onSetupSuccess;
  final bool isDesktop;
  const CompleteSetupPage(this.onSetupSuccess, this.isDesktop, {super.key});

  @override
  Widget build(BuildContext context) {
    return SetupPageWrapper(
      isDesktop,
      "Go to Sprout",
      onSetupSuccess,
      Column(
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
        ],
      ),
    );
  }
}
