import 'package:flutter/material.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/widgets/notification.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';
import 'package:sprout/user/widgets/user_config.dart';

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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.isDesktop ? 64 : 36),
            textAlign: TextAlign.center,
          ),
          Text(
            "Now that we have your user info, feel free to customize Sprout a bit below. You can always update these later.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: widget.isDesktop ? 20 : 16),
          ),
          if (_message.isNotEmpty)
            SproutNotificationWidget(SproutNotification(_message, theme.colorScheme.error, theme.colorScheme.onError)),
          UserConfigPage(
            onlyShowSetup: true,
            onSet: () {
              setState(() {
                _message = "";
              });
            },
            onFail: (msg) {
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
