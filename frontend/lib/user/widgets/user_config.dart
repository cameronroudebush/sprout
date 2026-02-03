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
  /// Called when a config fails to update, if applicable
  final void Function(String msg)? onFail;

  /// Called when a config updates successfully
  final void Function()? onSet;

  /// If we only want to show setup supported fields
  final bool onlyShowSetup;
  const UserConfigPage({super.key, this.onlyShowSetup = false, this.onFail, this.onSet});

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
              onSettingUpdate: (val) => userConfig.privateMode = val,
              settingType: "bool",
              icon: Icons.visibility_off_outlined,
            ),
          ],
          "Finance Provider Settings": [
            UserDisplayInfo(
              title: "SimpleFIN API Token",
              hint: "The SimpleFIN API token used to get finance data automatically.",
              settingValue: userConfig.simpleFinToken,
              onSettingUpdate: (val) => userConfig.simpleFinToken = val,
              settingType: "string",
              icon: Icons.api,
              showOnSetup: true,
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
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 6),
                  child: ConnectionSetupField(disabled: true),
                ),
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

        // Filter what we want to display based on given options
        final filteredEntries = displayInfo.entries
            .map((entry) {
              final filteredItems = entry.value.where((item) {
                if (widget.onlyShowSetup) {
                  return item.showOnSetup == true;
                }
                return true;
              }).toList();
              return MapEntry(entry.key, filteredItems);
            })
            // Remove sections that are empty after filtering
            .where((entry) => entry.value.isNotEmpty);

        return Column(
          children: filteredEntries
              .map(
                (entry) => UserInfoCard(
                  name: entry.key,
                  info: entry.value,
                  onFail: widget.onFail,
                  onSet: widget.onSet,
                  renderCards: !widget.onlyShowSetup,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
