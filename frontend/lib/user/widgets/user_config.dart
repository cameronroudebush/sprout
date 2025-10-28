import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/setup/widgets/connection.dart';
import 'package:sprout/user/model/user_display_info.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/user_provider.dart';
import 'package:sprout/user/widgets/info_card.dart';

/// A page that display user account information along with configuration settings
class UserConfigPage extends StatefulWidget {
  const UserConfigPage({super.key});

  @override
  State<UserConfigPage> createState() => _UserConfigPageState();
}

class _UserConfigPageState extends State<UserConfigPage> {
  /// Returns the status of the last account sync
  String _getLastSyncStatus(ConfigProvider provider) {
    final config = provider.config;
    final lastScheduleTime = provider.getLastSyncStatus();
    String? lastScheduleStatus = "success";
    if (config == null) {
      lastScheduleStatus = "N/A";
    } else if (config.lastSchedulerRun?.status == "failed") {
      if (config.lastSchedulerRun?.failureReason == null) {
        lastScheduleStatus = "failed - unknown reason";
      } else {
        lastScheduleStatus = config.lastSchedulerRun?.failureReason;
      }
    }
    return "$lastScheduleTime${lastScheduleStatus == null ? "" : " - $lastScheduleStatus"}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<ConfigProvider, SSEProvider, UserConfigProvider, AccountProvider, UserProvider>(
      builder: (context, configProvider, sseProvider, userConfigProvider, accountProvider, userProvider, child) {
        final userConfig = userConfigProvider.currentUserConfig;
        if (userConfig == null) return Center(child: CircularProgressIndicator());
        final screenWidth = MediaQuery.of(context).size.width;
        final minButtonSize = screenWidth * .25;
        final displayInfo = {
          "user settings": [
            UserDisplayInfo(
              title: "Hide Account Balances",
              hint: "Toggle to hide balances across the app.",
              settingValue: userConfig.privateMode,
              settingType: "bool",
              icon: Icons.remove_red_eye,
            ),
          ],
          "app settings": [
            UserDisplayInfo(
              title: "Backend connection URL",
              hint: "The URL at which we are connecting to the backend.",
              settingValue: ConfigProvider.connectionUrl,
              settingType: "string",
              icon: Icons.wifi,
              child: Center(
                child: SizedBox(
                  width: screenWidth / 1.15,
                  child: ConnectionSetupField(disabled: true, minButtonSize: minButtonSize),
                ),
              ),
            ),
          ],
          "user information": [
            UserDisplayInfo(
              title: "Username",
              value: userProvider.currentUser?.username ?? "N/A",
              icon: Icons.account_circle,
              child: Center(
                child: ButtonWidget(
                  text: "Logout",
                  minSize: minButtonSize,
                  onPressed: () async {
                    final authProvider = Provider.of<UserProvider>(context, listen: false);
                    await authProvider.logout();
                  },
                ),
              ),
            ),
          ],
          "app details": [
            UserDisplayInfo(
              title: "App Version",
              icon: Icons.info_outline,
              child: Padding(
                padding: EdgeInsetsGeometry.directional(start: 12, end: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(text: 'Backend: ${configProvider.unsecureConfig?.version}'),
                    TextWidget(text: 'Frontend: ${configProvider.packageInfo.version}'),
                  ],
                ),
              ),
            ),
            UserDisplayInfo(
              title: "Last Background Sync Status",
              icon: Icons.schedule,
              value: _getLastSyncStatus(configProvider),
            ),
            UserDisplayInfo(
              title: "Backend Connection Status",
              icon: Icons.event_repeat,
              value: sseProvider.isConnected ? "Connected" : "Disconnected",
              child: Center(
                child: SproutTooltip(
                  message: accountProvider.manualSyncIsRunning
                      ? "Manual Sync is running"
                      : "Forces an account sync immediately",
                  child: ButtonWidget(
                    text: "Manual Account Sync",
                    minSize: minButtonSize,
                    onPressed: accountProvider.manualSyncIsRunning ? null : () => accountProvider.manualSync(),
                  ),
                ),
              ),
            ),
          ],
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[...displayInfo.entries.map((entry) => UserInfoCard(name: entry.key, info: entry.value))],
        );
      },
    );
  }
}
