import 'package:flutter/material.dart';

/// A reusable app bar that places the sprout logo at the top and handles sizing
class SproutAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Optional list of actions to display in the app bar.
  final List<Widget>? actions;

  /// Optional widget to display at the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  /// The background color of the app bar. Defaults to Theme.of(context).colorScheme.onSecondaryContainer.
  final Color? backgroundColor;

  /// The height of the toolbar. This should be calculated using MediaQuery.
  final double toolbarHeight;

  const SproutAppBar({
    super.key,
    this.actions,
    this.bottom,
    this.backgroundColor,
    required this.toolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolbarHeight,
      title: Image.asset(
        'assets/logo/color-transparent-no-tag.png',
        width: MediaQuery.of(context).size.height * .2,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
      centerTitle: true,
      elevation: 0, // Remove shadow for a flat design
      actions: actions, // Use the provided actions
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
      bottom:
          bottom ??
          PreferredSize(
            preferredSize: const Size.fromHeight(8.0),
            child: Container(
              color: Theme.of(context).colorScheme.secondary.withAlpha(100),
              height: 8.0,
            ),
          ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 8.0));
}
