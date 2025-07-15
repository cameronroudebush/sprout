import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/config.dart';
import 'package:sprout/provider/auth.dart';
import 'package:sprout/widgets/button.dart';
import 'package:sprout/widgets/text.dart'; // Assuming this is your custom TextWidget
import 'package:timeago/timeago.dart' as timeago;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final configAPI = Provider.of<ConfigAPI>(context, listen: false);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // App Information Card
            _buildCard([
              TextWidget(
                referenceSize: 1.6,
                text: "App Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(height: 32.0, thickness: 1.0),
              _buildInfoRow(
                context,
                label: "App Version",
                value: configAPI.unsecureConfig!.version,
                icon: Icons.info_outline,
              ),
              SizedBox(height: 12),
              _buildInfoRow(
                context,
                label: "Last Schedule Run",
                value: configAPI.config?.lastSchedulerRun.time != null
                    ? timeago.format(
                        configAPI.config!.lastSchedulerRun.time.toLocal(),
                      )
                    : "N/A",
                icon: Icons.schedule,
              ),
              SizedBox(height: 12),
              _buildInfoRow(
                context,
                label: "Last Schedule Status",
                value:
                    "${configAPI.config?.lastSchedulerRun.status}${configAPI.config?.lastSchedulerRun.status == "failed" ? " - ${configAPI.config?.lastSchedulerRun.failureReason}" : ""}",
                icon: Icons.safety_check_rounded,
              ),
            ]),

            // User Information Card
            _buildCard([
              TextWidget(
                referenceSize: 1.6,
                text: "User Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
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
                minSize: MediaQuery.of(context).size.width * .5,
                text: "Logout",
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  /// Builds a generic themed card for display on this page
  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  // Helper method to build consistent info rows
  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12.0),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                referenceSize: 1.2,
                text: label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4.0),
              TextWidget(
                referenceSize: 1,
                text: value,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
