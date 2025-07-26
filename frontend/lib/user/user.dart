import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/model/config.dart';
import 'package:sprout/user/model/user_display_info.dart';
import 'package:sprout/user/provider.dart';
import 'package:sprout/user/widgets/info_card.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A page that display user account information along with other useful info
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  /// Returns the status of the last account sync
  String _getLastSyncStatus(Configuration? config) {
    final lastScheduleTime = config?.lastSchedulerRun.time != null
        ? timeago.format(config!.lastSchedulerRun.time!.toLocal())
        : "N/A";
    String? lastScheduleStatus = "success";
    if (config == null) {
      lastScheduleStatus = "N/A";
    } else if (config.lastSchedulerRun.status == "failed") {
      if (config.lastSchedulerRun.failureReason == null) {
        lastScheduleStatus = "failed - unknown reason";
      } else {
        lastScheduleStatus = config.lastSchedulerRun.failureReason;
      }
    }
    return "$lastScheduleTime${lastScheduleStatus == null ? "" : " - $lastScheduleStatus"}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<ConfigProvider, SSEProvider, AuthProvider, AccountProvider, UserProvider>(
      builder: (context, configProvider, sseProvider, authProvider, accountProvider, userProvider, child) {
        final userConfig = userProvider.currentUserConfig!;
        final minButtonSize = MediaQuery.of(context).size.width * .5;
        final displayInfo = {
          "settings": [
            UserDisplayInfo(
              title: "Hide Account Balances",
              hint: "If you would like to hide your account balances, toggle this to true.",
              settingValue: userConfig.privateMode,
              settingType: "bool",
              icon: Icons.remove_red_eye,
            ),
          ],
          "user information": [
            UserDisplayInfo(
              title: "Username",
              value: authProvider.currentUser?.username ?? "N/A",
              icon: Icons.account_circle,
              child: Center(
                child: ButtonWidget(
                  text: "Logout",
                  minSize: minButtonSize,
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
              value: _getLastSyncStatus(configProvider.config),
            ),
            UserDisplayInfo(
              title: "Backend Connection Status",
              icon: Icons.event_repeat,
              value: sseProvider.isConnected ? "Connected" : "Disconnected",
              child: Center(
                child: SproutTooltip(
                  message: "Forces an account sync immediately",
                  child: ButtonWidget(
                    text: "Manual Account Sync",
                    minSize: minButtonSize,
                    onPressed: () => accountProvider.manualSync(),
                  ),
                ),
              ),
            ),
          ],
        };
        ;
        // final headerStyling = TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary);

        // final lastScheduleTime = config?.lastSchedulerRun.time != null
        //     ? timeago.format(config!.lastSchedulerRun.time!.toLocal())
        //     : "N/A";
        // String? lastScheduleStatus = "success";
        // if (config == null) {
        //   lastScheduleStatus = "N/A";
        // } else if (config.lastSchedulerRun.status == "failed") {
        //   if (config.lastSchedulerRun.failureReason == null) {
        //     lastScheduleStatus = "failed - unknown reason";
        //   } else {
        //     lastScheduleStatus = config.lastSchedulerRun.failureReason;
        //   }
        // }
        // final combinedScheduleDisplay =
        //     "$lastScheduleTime${lastScheduleStatus == null ? "" : " - $lastScheduleStatus"}";
        // final minButtonSize = MediaQuery.of(context).size.width * .5;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ...displayInfo.entries.map((entry) => UserInfoCard(name: entry.key, info: entry.value)),
                // App Information Card
                // _buildCard([
                //   TextWidget(referenceSize: 1.6, text: "App Details", style: headerStyling),
                //   const Divider(height: 32.0, thickness: 1.0),
                //   _buildInfoRow(
                //     context,
                //     label: "App Version",
                //     value: [
                //       'Backend: ${configProvider.unsecureConfig?.version}',
                //       'Frontend: ${configProvider.packageInfo.version}',
                //     ],
                //     icon: Icons.info_outline,
                //   ),
                //   SizedBox(height: 12),
                //   _buildInfoRow(
                //     context,
                //     label: "Last Background Sync Status",
                //     value: combinedScheduleDisplay,
                //     icon: Icons.schedule,
                //   ),
                //   const SizedBox(height: 12),
                //   _buildInfoRow(
                //     context,
                //     label: "SSE Status",
                //     value: sseProvider.isConnected ? "Connected" : "Disconnected",
                //     icon: Icons.event_repeat,
                //   ),
                //   if (kDebugMode) ...[
                //     SizedBox(height: 12),
                //     ButtonWidget(
                //       text: "Manual Account Sync",
                //       minSize: minButtonSize,
                //       onPressed: () => accountProvider.manualSync(),
                //     ),
                //   ],
                // ]),

                // // User Information Card
                // _buildCard([
                //   TextWidget(referenceSize: 1.6, text: "User Information", style: headerStyling),
                //   const Divider(height: 32.0, thickness: 1.0),
                //   Consumer<AuthProvider>(
                //     builder: (context, authProvider, child) {
                //       return Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           _buildInfoRow(
                //             context,
                //             label: "Username",
                //             value: authProvider.currentUser?.username ?? "N/A",
                //             icon: Icons.person,
                //           ),
                //         ],
                //       );
                //     },
                //   ),
                //   SizedBox(height: 24),
                //   ButtonWidget(
                //     minSize: minButtonSize,
                //     text: "Logout",
                //     onPressed: () async {
                //       final authProvider = Provider.of<AuthProvider>(context, listen: false);
                //       await authProvider.logout();
                //     },
                //   ),
                // ]),
              ],
            ),
          ),
        );
      },
    );
  }
}
