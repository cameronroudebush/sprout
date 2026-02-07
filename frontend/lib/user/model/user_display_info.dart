import 'package:flutter/material.dart';

/// A class that provides information of what to display in the user cards
class UserDisplayInfo {
  /// What to call this info
  final String title;
  final IconData? icon;

  /// Intended only if we want to display a string, non-editable
  final String? value;

  /// Help text to display for this
  final String? hint;

  /// A child to render under this information
  final Widget? child;

  /// If we should render the child content in a row or a column
  final bool column;

  /// If this setting should be customizable during setup
  final bool showOnSetup;

  // If this is a setting, you should populate below
  final dynamic settingValue;
  final dynamic settingType;

  /// What to do when the setting value is updated. Throwing an error in this will fail the change
  final Future<void> Function(dynamic val)? onSettingUpdate;

  const UserDisplayInfo({
    required this.title,
    this.value,
    this.icon,
    this.hint,
    this.child,
    this.settingValue,
    this.settingType,
    this.column = true,
    this.onSettingUpdate,
    this.showOnSetup = false,
  });
}
