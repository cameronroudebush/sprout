import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/setup/widgets/connection.dart';
import 'package:sprout/user/model/user_display_info.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:sprout/user/user_provider.dart';
import 'package:sprout/user/widgets/info_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// A page that display user account information along with configuration settings
class UserConfigPage extends StatefulWidget {
  const UserConfigPage({super.key});

  @override
  State<UserConfigPage> createState() => _UserConfigPageState();
}

class _UserConfigPageState extends State<UserConfigPage> {
  /// Returns a formatted string for the last background sync status.
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
      builder: (context, configProvider, sseProvider, userConfigProvider, accountProvider, userProvider, _) {
        final userConfig = userConfigProvider.currentUserConfig;
        if (userConfig == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayInfo = {
          "User Settings": [
            UserDisplayInfo(
              title: "Hide Account Balances",
              hint: "Toggle to hide balances across the app.",
              settingValue: userConfig.privateMode,
              settingType: "bool",
              icon: Icons.visibility_off_outlined,
            ),
          ],
          "App Information": [
            UserDisplayInfo(
              title: "App Version",
              icon: Icons.info_outline,
              value:
                  'Backend: ${configProvider.unsecureConfig?.version ?? 'N/A'}\nFrontend: ${configProvider.packageInfo.version}',
            ),
            UserDisplayInfo(
              title: "Help & Documentation",
              icon: Icons.help_outline,
              hint: "Need help? Check out our documentation.",
              column: false,
              child: IconButton.filled(
                icon: Icon(Icons.help),
                onPressed: () => launchUrl(Uri.parse("https://sprout.croudebush.net")),
              ),
            ),
          ],
          "Connection Details": [
            if (!kIsWeb)
              UserDisplayInfo(
                title: "Backend Connection URL",
                hint: "The URL for the backend connection.",
                icon: Icons.http,
                child: Center(child: ConnectionSetupField(disabled: true)),
              ),
            UserDisplayInfo(
              title: "Last Background Sync Status",
              icon: Icons.schedule,
              value: _getLastSyncStatus(configProvider),
            ),
            UserDisplayInfo(
              title: "Real-time Connection Status",
              icon: Icons.sync,
              value: sseProvider.isConnected ? "Connected" : "Disconnected",
            ),
            UserDisplayInfo(
              title: "Manual Account Sync",
              icon: Icons.sync_problem,
              hint: "Force an immediate synchronization of your accounts.",
              column: false,
              child: FilledButton(
                onPressed: accountProvider.manualSyncIsRunning ? null : () => accountProvider.manualSync(),
                child: accountProvider.manualSyncIsRunning
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync),
              ),
            ),
          ],
        };

        return Column(
          children: displayInfo.entries.map((entry) => UserInfoCard(name: entry.key, info: entry.value)).toList(),
        );
      },
    );
  }
}
