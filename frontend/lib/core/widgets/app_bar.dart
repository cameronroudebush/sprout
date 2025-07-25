import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/text.dart';

/// The bar at the top of the screen we wish to render
class SproutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenHeight;
  final String currentPage;
  const SproutAppBar({super.key, required this.screenHeight, required this.currentPage});

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * .075);

  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: currentPage.toLowerCase() == "home" ? _homeContent(context) : _otherContent(context),
      ),
      centerTitle: true,
      elevation: 0, // Remove shadow for a flat design
      backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8.0),
        child: Container(color: Theme.of(context).colorScheme.secondary.withAlpha(100), height: 8.0),
      ),
    );
  }

  Widget _otherContent(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: SizedBox.shrink()),
        TextWidget(
          referenceSize: 2,
          text: currentPage,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: SizedBox(
            height: mediaQuery.size.height * .065,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/icon/favicon-color.png',
                  width: mediaQuery.size.height * .1,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _homeContent(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo/color-transparent-no-tag.png',
          width: mediaQuery.size.height * .15,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ],
    );
  }
}
