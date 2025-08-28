import 'package:flutter/material.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/setup/connection.dart';

/// Renders a connection setup and some information, normally used for first time setup
class ConnectionSetup extends StatelessWidget {
  const ConnectionSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            TextWidget(
              referenceSize: 3,
              text: "Connection Setup",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextWidget(
              referenceSize: 1.25,
              text:
                  "Due to Sprouts nature of being self hosted, you must provide a URL to connect to your instance. Please enter the URL below. You will be able to change this later if the connection fails.",
            ),

            ConnectionSetupField(
              onURLSet: () {
                SproutNavigator.redirect("home");
              },
            ),
          ],
        ),
      ),
    );
  }
}
