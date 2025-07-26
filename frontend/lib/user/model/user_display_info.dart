import 'package:flutter/material.dart';

/// A class that provides information of what to display in the user cards
class UserDisplayInfo {
  /// What to call this info
  final String title;
  final IconData? icon;
  final String? value;

  /// Help text to display for this
  final String? hint;

  /// A child to render under this information
  final Widget? child;

  // If this is a setting, you should populate below
  final dynamic settingValue;
  final dynamic settingType;

  const UserDisplayInfo({
    required this.title,
    this.value,
    this.icon,
    this.hint,
    this.child,
    this.settingValue,
    this.settingType,
  });
}
