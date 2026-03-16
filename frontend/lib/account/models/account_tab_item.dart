import 'package:flutter/material.dart';

/// A class that is used to define the account tabs
class AccountTabItem {
  final String label;
  final IconData icon;
  final Widget child;

  const AccountTabItem({required this.label, required this.icon, required this.child});
}
