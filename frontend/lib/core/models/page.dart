import 'package:flutter/material.dart';

/// This class defines a page to render in sprout
class SproutPage {
  /// The page we want to render
  final Widget page;

  /// An icon to identify what this page is
  final IconData icon;

  /// The name of this page
  final String label;

  /// Custom content to display on the app bar instead
  final Widget? customAppBar;

  /// Pages that are considered part of this page
  final List<SproutPage>? subPages;

  const SproutPage({required this.page, required this.icon, required this.label, this.customAppBar, this.subPages});
}
