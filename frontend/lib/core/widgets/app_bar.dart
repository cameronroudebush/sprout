import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/layout.dart';

/// The bar at the top of the screen we wish to render
class SproutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenHeight;

  /// Buttons we should show on the app bar
  final Widget Function(BuildContext context, bool isDesktop)? buttonBuilder;

  const SproutAppBar({super.key, required this.screenHeight, this.buttonBuilder});

  static double getHeightFromScreenHeight(double screenHeight) {
    return screenHeight * .06;
  }

  @override
  Size get preferredSize => Size.fromHeight(getHeightFromScreenHeight(screenHeight));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SproutLayoutBuilder((isDesktop, context) {
      final logo = isDesktop
          ? Image.asset(
              'assets/logo/color-transparent-no-tag.png',
              width: screenHeight * .12,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            )
          : Image.asset('assets/icon/color.png', width: 48, fit: BoxFit.contain, filterQuality: FilterQuality.high);

      final buttons = buttonBuilder != null ? buttonBuilder!(context, isDesktop) : null;

      final content = isDesktop
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [logo, ?buttons]),
            )
          : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [?buttons, logo]);

      return AppBar(
        toolbarHeight: preferredSize.height,
        scrolledUnderElevation: 0,
        title: content,
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0, // Remove shadow for a flat design
        backgroundColor: theme.colorScheme.primaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: Container(color: theme.colorScheme.secondary, height: 8.0),
        ),
      );
    });
  }
}
