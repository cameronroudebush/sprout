import 'package:flutter/material.dart';

/// The bar at the top of the screen we wish to render
class SproutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenHeight;

  /// Content we should display instead
  final Widget? contentOverride;

  const SproutAppBar({super.key, required this.screenHeight, this.contentOverride});

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * .06);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      toolbarHeight: preferredSize.height,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: const EdgeInsets.all(12),
        child:
            contentOverride ??
            Image.asset(
              'assets/logo/color-transparent-no-tag.png',
              width: screenHeight * .12,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
      ),
      centerTitle: true,
      elevation: 0, // Remove shadow for a flat design
      backgroundColor: theme.colorScheme.primaryContainer,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8.0),
        child: Container(color: theme.colorScheme.secondary, height: 8.0),
      ),
    );
  }
}
