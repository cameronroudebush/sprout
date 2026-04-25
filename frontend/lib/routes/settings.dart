import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/config/widgets/settings_section.dart';
import 'package:sprout/config/widgets/tiles/action_tile.dart';
import 'package:sprout/config/widgets/tiles/switch_tile.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/shared/providers/widget_provider.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// A page that allows customization of Sprout
class SettingsPage extends ConsumerWidget {
  /// If enabled, only shows settings that can be set on setup
  final bool onlyShowSetup;

  /// Called whenever a configuration value is successfully changed
  final VoidCallback? onConfigChanged;

  /// Called whenever a configuration change fails
  final void Function(dynamic error)? onConfigFailure;

  const SettingsPage({super.key, this.onlyShowSetup = false, this.onConfigChanged, this.onConfigFailure});

  /// Central function to handle config updates
  Future<void> _update(WidgetRef ref, void Function(UserConfig) callback) async {
    try {
      await ref.read(userConfigProvider.notifier).updateConfig(callback);
      onConfigChanged?.call();
    } catch (e) {
      if (onConfigFailure == null) {
        ref.read(notificationsProvider.notifier).openWithAPIException(e);
      } else {
        onConfigFailure?.call(e);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(secureConfigProvider).value;
    final user = ref.watch(authProvider).value;
    final userConfig = ref.watch(userConfigProvider).value;
    final sseConnected = ref.watch(sseProvider).isConnected;
    final unsecureConfig = ref.watch(unsecureConfigProvider).value;
    final packageInfo = ref.watch(packageInfoProvider).value;
    final accountsState = ref.watch(accountsProvider);
    final isSyncing = accountsState.value?.manualSyncIsRunning == true;
    final backendUrl = ref.watch(secureConfigApiProvider).value?.apiClient.basePath;

    if (userConfig == null || config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Define child lists for conditional sections
    final appearanceChildren = [
      ActionSettingTile(
        title: "App Theme",
        subtitle: "Customize how Sprout looks",
        icon: Icons.palette_outlined,
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<ThemeStyleEnum>(
            value: userConfig.themeStyle,
            alignment: Alignment.centerRight,
            onChanged: (ThemeStyleEnum? newValue) {
              if (newValue != null) {
                _update(ref, (c) => c.themeStyle = newValue);
              }
            },
            items: ThemeStyleEnum.values
                .map((style) => DropdownMenuItem(value: style, child: Text(style.value.toTitleCase)))
                .toList(),
          ),
        ),
      ),
    ];

    final privacyChildren = [
      if (!onlyShowSetup)
        SwitchSettingTile(
          title: "Private Mode",
          subtitle: "Hide balances across the app",
          icon: Icons.visibility_off_outlined,
          value: userConfig.privateMode,
          onChanged: (val) => _update(ref, (c) => c.privateMode = val),
        ),
      if (!kIsWeb)
        SwitchSettingTile(
          title: "Allow Widgets",
          subtitle: "Enable home screen widgets to access account data",
          icon: Icons.widgets_outlined,
          value: userConfig.allowWidgets,
          onChanged: (val) async {
            await _update(ref, (c) => c.allowWidgets = val);
            await ref.read(widgetSyncProvider.notifier).update();
          },
        ),
      if (!kIsWeb && !onlyShowSetup)
        SwitchSettingTile(
          title: "Biometric Lock",
          subtitle: "Require fingerprint to open Sprout",
          icon: Icons.fingerprint,
          value: userConfig.secureMode,
          onChanged: (val) async {
            try {
              await ref.read(biometricsProvider.notifier).toggleSecureMode(val);
              onConfigChanged?.call();
            } catch (e) {
              ref.read(notificationsProvider.notifier).openWithAPIException(e);
              onConfigFailure?.call(e);
            }
          },
        ),
    ];

    final userHasEmail = user != null && user.email != null && user.email!.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 8),
      child: SproutRouteWrapper(
        child: Column(
          spacing: 16,
          children: [
            // Profile
            SettingSection(
              title: "User Profile",
              children: [
                ActionSettingTile(
                  title: "Username",
                  subtitle: user?.username ?? "Unknown",
                  icon: Icons.person_outline,
                  trailing: SizedBox.shrink(),
                ),
                ActionSettingTile(
                  title: "Email Address",
                  subtitle: user?.email ?? "No email set",
                  icon: Icons.email_outlined,
                  onTap: () => _showEmailDialog(
                    context: context,
                    currentEmail: user?.email,
                    onSave: (newEmail) async {
                      try {
                        await ref.read(authProvider.notifier).updateUser(UpdateUserDto(email: newEmail));
                      } catch (e) {
                        ref.read(notificationsProvider.notifier).openWithAPIException(e);
                        onConfigFailure?.call(e);
                      }
                    },
                  ),
                ),
                if (config.emailEnabled)
                  ActionSettingTile(
                    title: "Email Frequency",
                    subtitle: "How often to receive finance updates",
                    icon: Icons.notifications_active_outlined,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<EmailUpdateFrequencyEnum>(
                        value: userConfig.emailUpdateFrequency,
                        alignment: Alignment.centerRight,
                        onChanged: !userHasEmail
                            ? null
                            : (EmailUpdateFrequencyEnum? newValue) {
                                if (newValue != null) {
                                  _update(ref, (c) => c.emailUpdateFrequency = newValue);
                                }
                              },
                        items: EmailUpdateFrequencyEnum.values
                            .map((freq) => DropdownMenuItem(
                                  value: freq,
                                  child: Text(freq.value.toTitleCase),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),

            // Appearance (Always shown as it has children)
            SettingSection(title: "Appearance", children: appearanceChildren),

            // Privacy & Security (Only shown if children exist)
            if (privacyChildren.isNotEmpty) SettingSection(title: "Privacy & Security", children: privacyChildren),

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
                    onSave: (val) => _update(ref, (c) => c.simpleFinToken = val),
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
                      onSave: (val) => _update(ref, (c) => c.geminiKey = val),
                    ),
                  ),
              ],
            ),

            // System details
            if (!onlyShowSetup)
              SettingSection(
                title: "System Details",
                children: [
                  ActionSettingTile(
                    title: "Background Sync",
                    subtitle: "Request a fresh sync of all providers",
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
                    trailing: Padding(
                      padding: EdgeInsetsGeometry.only(right: 14),
                      child: Icon(Icons.circle, color: sseConnected ? Colors.green : Colors.red, size: 12),
                    ),
                  ),
                  ActionSettingTile(
                    title: "Sprout Documentation",
                    subtitle: "Need some help? Get it here.",
                    icon: Icons.help,
                    onTap: () => launchUrl(Uri.parse("https://sprout.croudebush.net")),
                  ),
                  ActionSettingTile(
                    title: "Connection Url",
                    subtitle: "The Url of the server we're connected to.",
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
                        Text(
                          "Backend: ${unsecureConfig?.version ?? ""}",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
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

    showSproutPopup(
      context: context,
      builder: (context) => SproutBaseDialogWidget(
        "Update $provider Token",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Text(
              "Enter your new token below. This will be encrypted and stored securely.",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            // Input for the API token
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
                        child: const Text(
                          "Save",
                        ),
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

  /// Shows a dialog specifically for updating the email address
  void _showEmailDialog({
    required BuildContext context,
    required String? currentEmail,
    required Function(String) onSave,
  }) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentEmail);
    final isChanged = ValueNotifier<bool>(false);

    controller.addListener(() {
      final text = controller.text.trim();
      // Basic validation: must be different and contain an @
      isChanged.value = text != (currentEmail ?? "") && text.contains('@');
    });

    showSproutPopup(
      context: context,
      builder: (context) => SproutBaseDialogWidget(
        "Update Email",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            Text(
              "Update your contact email address for additional app features.",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isChanged,
                    builder: (context, changed, _) {
                      return FilledButton(
                        onPressed: changed
                            ? () {
                                onSave(controller.text.trim());
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text("Update"),
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
