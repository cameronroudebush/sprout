import 'package:flutter/material.dart';
import 'package:sprout/routes/settings.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';

/// This page contains the setup process for allowing the user to do some configuration during setup
class UserConfigSetupPage extends StatefulWidget {
  final VoidCallback nextPage;
  final bool isDesktop;
  const UserConfigSetupPage(this.nextPage, this.isDesktop, {super.key});

  @override
  State<UserConfigSetupPage> createState() => _UserConfigSetupPageState();
}

class _UserConfigSetupPageState extends State<UserConfigSetupPage> {
  String _message = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SetupPageWrapper(
      widget.isDesktop,
      "Complete Configuration",
      widget.nextPage,
      Column(
        spacing: 24,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'User Configuration',
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            "Now that we have your user info, feel free to customize Sprout a bit below. You can always update these later.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          if (_message.isNotEmpty)
            SproutNotificationWidget(SproutNotification(_message, theme.colorScheme.error, theme.colorScheme.onError)),
          SettingsPage(
            onlyShowSetup: true,
            onConfigChanged: () {
              setState(() {
                _message = "";
              });
            },
            onConfigFailure: (msg) {
              setState(() {
                _message = msg;
              });
            },
          ),
        ],
      ),
    );
  }
}
