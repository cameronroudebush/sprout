import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/config/widgets/settings_section.dart';
import 'package:sprout/config/widgets/tiles/action_tile.dart';
import 'package:sprout/config/widgets/tiles/switch_tile.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/dialog/edit_dialog.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/shared/providers/widget_provider.dart';
import 'package:sprout/theme/widgets/theme_picker.dart';
import 'package:sprout/user/models/extensions/use_config_extensions.dart';
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
  Future<void> _update(WidgetRef ref, UserConfig Function(UserConfig) callback) async {
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

  /// Opens a new webpage to the documentation
  static Future<void> openDocumentation() async {
    await launchUrl(Uri.parse("https://sprout.croudebush.net"));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(secureConfigProvider).value;
    final user = ref.watch(authProvider).value;
    final userConfig = ref.watch(userConfigProvider).value;
    final sseConnected = ref.watch(sseProvider).isConnected;
    final unsecureConfig = ref.watch(unsecureConfigProvider).value;
    final packageInfo = ref.watch(packageInfoProvider).value;
    final accountsState = ref.watch(accountsProvider);
    final providers = ref.watch(providerConfigProvider).value;
    final isSyncing = accountsState.value?.manualSyncIsRunning == true;
    final backendUrl = ref.watch(secureConfigApiProvider).value?.apiClient.basePath;
    final simpleFinEnabled = providers?.firstWhereOrNull((x) => x.dbType == ProviderTypeEnum.simpleFin) != null;

    if (userConfig == null || config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userHasEmail = user != null && user.email != null && user.email!.isNotEmpty;
    final settingElevation = onlyShowSetup ? 0.0 : null;

// Sections, defined by a map for easier modification
    final Map<String, List<Widget>> sectionsMap = {
      "User Profile": [
        ActionSettingTile(
          title: "Username",
          subtitle: user?.username ?? "Unknown",
          icon: Icons.person_outline,
          trailing: const SizedBox.shrink(),
        ),
        ActionSettingTile(
          title: "Email Address",
          subtitle: user?.email ?? "No email set",
          icon: Icons.email_outlined,
          onTap: () => showSproutEditDialog(
            context: context,
            title: "Update Email",
            label: "Email Address",
            currentValue: user?.email,
            icon: Icons.email,
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
            subtitle: !userHasEmail
                ? "You must configure an email to set this value"
                : "How often to receive finance updates",
            icon: Icons.notifications_active_outlined,
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<EmailUpdateFrequencyEnum>(
                value: userConfig.emailUpdateFrequency,
                alignment: Alignment.centerRight,
                onChanged: !userHasEmail
                    ? null
                    : (EmailUpdateFrequencyEnum? newValue) {
                        if (newValue != null) {
                          _update(ref, (c) => c.copyWith(emailUpdateFrequency: newValue));
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
      "Appearance": [
        ThemePicker(
          currentStyle: userConfig.themeStyle,
          onThemeChanged: (ThemeStyleEnum style) {
            _update(ref, (c) => c.copyWith(themeStyle: style));
          },
        ),
        ActionSettingTile(
          title: "Display Currency",
          subtitle: "Customize what currency you want to see your finances in",
          icon: Icons.currency_exchange,
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<CurrencyOptionsEnum>(
              value: userConfig.currency,
              alignment: Alignment.centerRight,
              onChanged: (CurrencyOptionsEnum? newValue) {
                if (newValue != null) {
                  _update(ref, (c) => c.copyWith(currency: newValue));
                }
              },
              items: CurrencyOptionsEnum.values
                  .map((style) => DropdownMenuItem(
                      value: style,
                      child: Text(
                          "${NumberFormat.simpleCurrency(name: style.toString()).currencySymbol} - ${style.value}")))
                  .toList(),
            ),
          ),
        ),
      ],
      "Privacy & Security": [
        if (!onlyShowSetup)
          SwitchSettingTile(
            title: "Private Mode",
            subtitle: "Hide balances across the app",
            icon: Icons.visibility_off_outlined,
            value: userConfig.privateMode,
            onChanged: (val) => _update(ref, (c) => c.copyWith(privateMode: val)),
          ),
        if (!kIsWeb)
          SwitchSettingTile(
            title: "Allow Widgets",
            subtitle: "Enable home screen widgets to access account data",
            icon: Icons.widgets_outlined,
            value: userConfig.allowWidgets,
            onChanged: (val) async {
              await _update(ref, (c) => c.copyWith(allowWidgets: val));
              await ref.read(widgetSyncProvider.notifier).updateData();
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
      ],
      "Integrations": [
        if (simpleFinEnabled)
          ActionSettingTile(
            title: "SimpleFIN Token",
            subtitle: userConfig.simpleFinToken?.isNotEmpty == true ? "Token Set" : "Configure Token",
            icon: Icons.api,
            onTap: () => showSproutEditDialog(
              context: context,
              title: "Update SimpleFIN Token",
              label: "SimpleFIN API Token",
              currentValue: userConfig.simpleFinToken,
              icon: Icons.key,
              obscureText: true,
              description: "Enter your new token below. This will be encrypted and stored securely.",
              onSave: (val) => _update(ref, (c) => c.copyWith(simpleFinToken: val)),
            ),
          ),
        if (!config.chatKeyProvidedInBackend)
          ActionSettingTile(
            title: "Gemini AI Key",
            subtitle: userConfig.geminiKey?.isNotEmpty == true ? "Token Set" : "Configure Token",
            icon: Icons.auto_awesome,
            onTap: () => showSproutEditDialog(
              context: context,
              title: "Update Gemini Token",
              label: "Gemini API Token",
              currentValue: userConfig.geminiKey,
              icon: Icons.key,
              obscureText: true,
              description: "Enter your new token below. This will be encrypted and stored securely.",
              onSave: (val) => _update(ref, (c) => c.copyWith(geminiKey: val)),
            ),
          ),
      ],
      "System Details": [
        if (!onlyShowSetup) ...[
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
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.circle, color: sseConnected ? Colors.green : Colors.red, size: 12),
            ),
          ),
          ActionSettingTile(
            title: "Sprout Documentation",
            subtitle: "Need some help? Get it here",
            icon: Icons.help,
            onTap: () => openDocumentation(),
          ),
          ActionSettingTile(
            title: "Connection Url",
            subtitle: "The Url of the server we're connected to",
            icon: Icons.http,
            trailing: Text(backendUrl ?? "", style: theme.textTheme.labelMedium),
          ),
          ActionSettingTile(
            title: "Version",
            icon: Icons.info_outline,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Frontend: ${packageInfo?.version ?? ""}", style: theme.textTheme.labelMedium),
                Text("Backend: ${unsecureConfig?.version ?? ""}", style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        ],
      ],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: SproutRouteWrapper(
        child: Column(
          spacing: 16,
          children: sectionsMap.entries
              // Filter out sections where the children list is completely empty
              .where((entry) => entry.value.isNotEmpty)
              .map((entry) => SettingSection(
                    elevation: settingElevation,
                    title: entry.key,
                    children: entry.value,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
