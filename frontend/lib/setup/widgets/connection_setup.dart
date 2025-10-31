import 'package:flutter/material.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/setup/widgets/connection.dart';

/// Renders a connection setup and some information, normally used for first time setup
class ConnectionSetup extends StatelessWidget {
  const ConnectionSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            Text("Connection Setup", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36)),
            Text(
              "Due to Sprouts nature of being self hosted, you must provide a URL to connect to your instance. Please enter the URL below. You will be able to change this later if the connection fails.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
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
