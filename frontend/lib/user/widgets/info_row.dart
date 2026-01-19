import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/user/model/user_display_info.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Provides a row of info to display in the card structure of the user page
// ignore: must_be_immutable
class UserInfoRow extends StatelessWidget {
  final UserDisplayInfo info;
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;

  UserInfoRow({super.key, required this.info}) {
    if (info.settingValue is String) _textController.text = info.settingValue ?? '';
  }

  void _updateVal(dynamic val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Don't allow too often of updates
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = ServiceLocator.get<UserConfigProvider>();
      if (info.onSettingUpdate != null) info.onSettingUpdate!(val);
      provider.updateConfig(provider.currentUserConfig!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserConfigProvider>(
      builder: (context, userProvider, child) {
        final mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            if (info.hint != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  info.hint!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.start,
                ),
              ),
            if (info.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(info.value!, style: const TextStyle()),
              ),
            if (info.child != null && info.column)
              Padding(padding: const EdgeInsets.only(top: 8.0), child: info.child!),
          ],
        );

        Widget rowContent = mainContent;
        if (info.settingType == "bool" && info.settingValue is bool) {
          rowContent = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: mainContent),
              Switch(value: info.settingValue, onChanged: _updateVal),
            ],
          );
        } else if (info.settingType == "string" && info.settingValue is String) {
          rowContent = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 36,
            children: [
              mainContent,
              Expanded(
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onChanged: _updateVal,
                ),
              ),
            ],
          );
        } else if (!info.column) {
          rowContent = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 4,
            children: [
              Expanded(child: mainContent),
              if (info.child != null) info.child!,
            ],
          );
        }

        return ListTile(
          leading: info.icon != null ? Icon(info.icon, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
          title: rowContent,
        );
      },
    );
  }
}
