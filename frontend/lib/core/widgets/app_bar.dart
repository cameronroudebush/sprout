import 'package:flutter/material.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';

/// The bar at the top of the screen we wish to render
class SproutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenHeight;
  final String? currentPage;
  const SproutAppBar({super.key, required this.screenHeight, this.currentPage});

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * .075);

  Widget build(BuildContext context) {
    Widget page = _blankBar(context, null);
    final currentPageLower = currentPage?.toLowerCase();
    if (currentPageLower == "accounts") {
      page = _accountPage(context);
    } else if (currentPageLower == "home") {
      page = _homeContent(context);
    }

    return AppBar(
      toolbarHeight: preferredSize.height,
      scrolledUnderElevation: 0,
      title: Padding(padding: EdgeInsetsGeometry.all(12), child: page),
      centerTitle: true,
      elevation: 0, // Remove shadow for a flat design
      backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8.0),
        child: Container(color: Theme.of(context).colorScheme.secondary.withAlpha(100), height: 8.0),
      ),
    );
  }

  /// An empty bar that shows the page name and the sprout icon, that's it
  Widget _blankBar(BuildContext context, Widget? leadingContent) {
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: leadingContent ?? SizedBox.shrink()),
        TextWidget(
          referenceSize: 2,
          text: currentPage ?? "",
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

  /// Renders what to show on the account page
  Widget _accountPage(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return _blankBar(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add button
          SproutTooltip(
            message: "Add an account",
            child: ButtonWidget(
              icon: Icons.add,
              height: mediaQuery.size.height * .035,
              minSize: mediaQuery.size.width * .1,
              onPressed: () async {
                // Open the add account dialog
                await showDialog(context: context, builder: (_) => AddAccountDialog());
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Renders what to show on the home page
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
