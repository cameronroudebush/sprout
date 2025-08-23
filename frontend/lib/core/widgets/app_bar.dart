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
  Size get preferredSize => Size.fromHeight(screenHeight * .06);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget pageContent;
    switch (currentPage?.toLowerCase()) {
      case "accounts":
        pageContent = _accountPage(context);
        break;
      case "home":
      case "setup":
        pageContent = _homeContent(context);
        break;
      default:
        pageContent = _blankBar(context, null);
    }

    return AppBar(
      toolbarHeight: preferredSize.height,
      scrolledUnderElevation: 0,
      title: Padding(padding: const EdgeInsets.all(12), child: pageContent),
      centerTitle: true,
      elevation: 0, // Remove shadow for a flat design
      backgroundColor: theme.colorScheme.primaryContainer,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8.0),
        child: Container(color: theme.colorScheme.secondary.withAlpha(100), height: 8.0),
      ),
    );
  }

  /// An empty bar that shows the page name and the sprout icon.
  Widget _blankBar(BuildContext context, Widget? leadingContent) {
    return Row(
      children: [
        // The leading content on the left.
        Expanded(child: leadingContent ?? const SizedBox.shrink()),
        // The page title in the center.
        TextWidget(
          referenceSize: 2,
          text: currentPage ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // The icon on the right, aligned properly.
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Image.asset(
              'assets/icon/favicon-color.png',
              height: preferredSize.height * 0.85,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }

  /// Renders the content for the "Accounts" page app bar.
  Widget _accountPage(BuildContext context) {
    return _blankBar(
      context,
      Align(
        alignment: Alignment.centerLeft,
        child: SproutTooltip(
          message: "Add an account",
          child: ButtonWidget(
            icon: Icons.add,
            height: screenHeight * .035,
            minSize: MediaQuery.of(context).size.width * .1,
            onPressed: () async {
              // Open the add account dialog
              await showDialog(context: context, builder: (_) => const AddAccountDialog());
            },
          ),
        ),
      ),
    );
  }

  /// Renders the content for the "Home" and "Setup" page app bars.
  Widget _homeContent(BuildContext context) {
    return Image.asset(
      'assets/logo/color-transparent-no-tag.png',
      width: screenHeight * .12,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
