import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/config/models/extensions/config_extension.dart';
import 'package:sprout/config/widgets/settings_section.dart';
import 'package:sprout/config/widgets/tiles/action_tile.dart';
import 'package:sprout/config/widgets/tiles/switch_tile.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/shared/providers/widget_provider.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserConfigPage extends ConsumerWidget {
  const UserConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(secureConfigProvider).value;
    final userConfig = ref.watch(userConfigProvider).value;
    final sseConnected = ref.watch(sseProvider).isConnected;
    final unsecureConfig = ref.watch(unsecureConfigProvider).value;
    final packageInfo = ref.watch(packageInfoProvider).value;
    final accountsState = ref.watch(accountsProvider);
    final isSyncing = accountsState.value?.manualSyncIsRunning == true;
    final backendUrl = ref.watch(secureConfigApiProvider).value?.apiClient.basePath;

    final provider = ref.read(userConfigProvider.notifier);

    if (userConfig == null || config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsetsGeometry.only(top: 12),
      child: Column(
        spacing: 16,
        children: [
          // Appearance Settings
          // TODO: Add back once backend has support
          // SettingSection(
          //   title: "Appearance",
          //   children: [
          //     ActionSettingTile(
          //       title: "App Theme",
          //       subtitle: "Customize how Sprout looks",
          //       icon: Icons.palette_outlined,
          //       trailing: DropdownButtonHideUnderline(
          //         child: DropdownButton<String>(
          //           value: userConfig.theme ?? 'dark', // Fallback to current config
          //           alignment: Alignment.centerRight,
          //           icon: const Icon(Icons.arrow_drop_down),
          //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //             color: Theme.of(context).colorScheme.primary,
          //             fontWeight: FontWeight.bold,
          //           ),
          //           onChanged: (String? newValue) {
          //             if (newValue != null) {
          //               provider.updateConfig((c) => c.theme = newValue);
          //             }
          //           },
          //           items: const [
          //             DropdownMenuItem(value: 'system', child: Text("System")),
          //             DropdownMenuItem(value: 'light', child: Text("Light")),
          //             DropdownMenuItem(value: 'dark', child: Text("Dark")),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // Privacy and security
          SettingSection(
            title: "Privacy & Security",
            children: [
              SwitchSettingTile(
                title: "Private Mode",
                subtitle: "Hide balances across the app",
                icon: Icons.visibility_off_outlined,
                value: userConfig.privateMode,
                onChanged: (val) => provider.updateConfig((c) => c.privateMode = val),
              ),
              if (!kIsWeb)
                SwitchSettingTile(
                  title: "Allow Widgets",
                  subtitle: "Enable home screen widgets to access account data",
                  icon: Icons.widgets_outlined,
                  value: userConfig.allowWidgets,
                  onChanged: (val) async {
                    await provider.updateConfig((c) => c.allowWidgets = val);
                    // Trigger the native widget update service
                    await ref.read(widgetSyncProvider.notifier).update();
                  },
                ),
              if (!kIsWeb)
                SwitchSettingTile(
                  title: "Biometric Lock",
                  subtitle: "Require fingerprint to open Sprout",
                  icon: Icons.fingerprint,
                  value: userConfig.secureMode,
                  onChanged: (val) async {
                    await provider.toggleSecureMode(val);
                  },
                ),
            ],
          ),

          // Integrations
          SettingSection(
            title: "Integrations",
            children: [
              ActionSettingTile(
                title: "SimpleFIN Token",
                subtitle: userConfig.simpleFinToken?.isNotEmpty == true ? "Token Set" : "Configure Token",
                icon: Icons.api,
                onTap: () => _showTokenDialog(
                  context: context,
                  provider: "SimpleFIN",
                  currentValue: userConfig.simpleFinToken,
                  onSave: (val) => provider.updateConfig((c) => c.simpleFinToken = val),
                ),
              ),
              if (!config.chatKeyProvidedInBackend)
                ActionSettingTile(
                  title: "Gemini AI Key",
                  subtitle: userConfig.geminiKey?.isNotEmpty == true ? "Token Set" : "Configure Token",
                  icon: Icons.auto_awesome,
                  onTap: () => _showTokenDialog(
                    context: context,
                    provider: "Gemini",
                    currentValue: userConfig.geminiKey,
                    onSave: (val) => provider.updateConfig((c) => c.geminiKey = val),
                  ),
                ),
            ],
          ),

          // System details
          SettingSection(
            title: "System Details",
            children: [
              ActionSettingTile(
                title: "Background Sync",
                subtitle: config.syncStatusString,
                icon: Icons.schedule,
                trailing: isSyncing
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => ref.read(accountsProvider.notifier).manualSync(),
                      ),
              ),
              ActionSettingTile(
                title: "Real-time Connection",
                subtitle: sseConnected ? "Connected" : "Disconnected",
                icon: Icons.sync,
                trailing: Icon(Icons.circle, color: sseConnected ? Colors.green : Colors.red, size: 12),
              ),
              ActionSettingTile(
                title: "Sprout Documentation",
                subtitle: "Need some help? Get it here.",
                icon: Icons.help,
                onTap: () => launchUrl(Uri.parse("https://sprout.croudebush.net")),
              ),
              ActionSettingTile(
                title: "Backend Connection Url",
                icon: Icons.http,
                trailing: Text(backendUrl ?? "", style: Theme.of(context).textTheme.labelMedium),
              ),
              ActionSettingTile(
                title: "Version",
                icon: Icons.info_outline,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Frontend: ${packageInfo?.version ?? ""}", style: Theme.of(context).textTheme.labelMedium),
                    Text("Backend: ${unsecureConfig?.version ?? ""}", style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows a branded bottom sheet to update a specific config field.
  /// The [onSave] callback handles the dynamic update logic.
  void _showTokenDialog({
    required BuildContext context,
    required String provider,
    required String? currentValue,
    required Function(String) onSave,
  }) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentValue);

    final isChanged = ValueNotifier<bool>(false);
    controller.addListener(() {
      isChanged.value = controller.text.trim() != (currentValue ?? "");
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5), width: 1),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Update $provider Token", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "Enter your new token below. This will be encrypted and stored securely.",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            // Input for the API token
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "$provider API Token",
                prefixIcon: const Icon(Icons.key),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => controller.clear()),
              ),
            ),
            // Bottom row of buttons
            const SizedBox(height: 24),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isChanged,
                    builder: (context, changed, child) {
                      return FilledButton(
                        onPressed: (changed && controller.text.trim().isNotEmpty)
                            ? () {
                                onSave(controller.text.trim());
                                Navigator.pop(context);
                              }
                            : null,
                        style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                        child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
