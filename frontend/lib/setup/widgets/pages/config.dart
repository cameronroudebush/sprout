import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/settings.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/user/user_config_provider.dart';

/// This page contains the setup process for allowing the user to do some configuration during setup
class UserConfigSetupPage extends ConsumerStatefulWidget {
  final VoidCallback nextPage;
  final bool isDesktop;
  const UserConfigSetupPage(this.nextPage, this.isDesktop, {super.key});

  @override
  ConsumerState<UserConfigSetupPage> createState() => _UserConfigSetupPageState();
}

class _UserConfigSetupPageState extends ConsumerState<UserConfigSetupPage> {
  String _message = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userConfigState = ref.watch(userConfigProvider).value;
    final secureConfig = ref.watch(secureConfigProvider).value;

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
      nextBtnIsLoading: userConfigState == null || secureConfig == null,
    );
  }
}
