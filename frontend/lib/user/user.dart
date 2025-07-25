import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/sse.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/user/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A page that display user account information along with other useful info
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer4<ConfigProvider, SSEProvider, UserProvider, AccountProvider>(
      builder: (context, configProvider, sseProvider, userProvider, accountProvider, child) {
        final config = configProvider.config;
        final headerStyling = TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary);

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
        final combinedScheduleDisplay =
            "$lastScheduleTime${lastScheduleStatus == null ? "" : " - $lastScheduleStatus"}";
        final minButtonSize = MediaQuery.of(context).size.width * .5;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // App Information Card
                _buildCard([
                  TextWidget(referenceSize: 1.6, text: "App Details", style: headerStyling),
                  const Divider(height: 32.0, thickness: 1.0),
                  _buildInfoRow(
                    context,
                    label: "App Version",
                    value: [
                      'Backend: ${configProvider.unsecureConfig?.version}',
                      'Frontend: ${configProvider.packageInfo.version}',
                    ],
                    icon: Icons.info_outline,
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    label: "Last Background Sync Status",
                    value: combinedScheduleDisplay,
                    icon: Icons.schedule,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    label: "SSE Status",
                    value: sseProvider.isConnected ? "Connected" : "Disconnected",
                    icon: Icons.event_repeat,
                  ),
                  if (kDebugMode) ...[
                    SizedBox(height: 12),
                    ButtonWidget(
                      text: "Manual Account Sync",
                      minSize: minButtonSize,
                      onPressed: () => accountProvider.manualSync(),
                    ),
                  ],
                ]),

                // User Information Card
                _buildCard([
                  TextWidget(referenceSize: 1.6, text: "User Information", style: headerStyling),
                  const Divider(height: 32.0, thickness: 1.0),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            context,
                            label: "Username",
                            value: authProvider.currentUser?.username ?? "N/A",
                            icon: Icons.person,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  ButtonWidget(
                    minSize: minButtonSize,
                    text: "Logout",
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                    },
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a generic themed card for display on this page
  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: children),
      ),
    );
  }

  // Helper method to build consistent info rows
  Widget _buildInfoRow(BuildContext context, {required String label, required dynamic value, IconData? icon}) {
    List<String> values = value is String ? [value] : value;
    List<Widget> display = values
        .map(
          (x) => TextWidget(
            referenceSize: 1,
            text: x,
            style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.onSurface),
          ),
        )
        .toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12.0),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                referenceSize: 1.2,
                text: label,
                style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4.0),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: display),
            ],
          ),
        ),
      ],
    );
  }
}
