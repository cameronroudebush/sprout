import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/models/page.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/router.dart';
import 'package:sprout/core/widgets/app_bar.dart';
import 'package:sprout/core/widgets/exit.dart';
import 'package:sprout/core/widgets/fab.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/core/widgets/scroll.dart';
import 'package:sprout/user/model/user_extensions.dart';
import 'package:sprout/user/user_provider.dart';

/// A wrapper around the scaffold that renders the navigation selection options as well as the current page
class SproutShell extends StatelessWidget {
  // This object is provided by GoRouter and contains the state of the branches.
  final Widget child;

  /// The current rendered page
  final SproutPage currentPage;

  /// If the app bar should be displayed
  final bool renderAppBar;

  /// If navigation should be rendered
  final bool renderNav;

  const SproutShell({
    required this.child,
    required this.currentPage,
    super.key,
    this.renderAppBar = true,
    this.renderNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      /// The app bar we want, if necessary
      final appBar = !renderAppBar
          ? null
          : SproutAppBar(screenHeight: mediaQuery.height, useFullLogo: currentPage.useFullLogo);

      // The page to render, considering scroll-ability, and some padding
      final padding = EdgeInsets.only(
        left: currentPage.pagePadding,
        right: currentPage.pagePadding,
        // This 80 pixels reserves space for the [FloatingActionButtonWidget]
        bottom: currentPage.scrollWrapper ? 80 : 0,
      );
      final page = currentPage.scrollWrapper
          ? SizedBox(
              width: mediaQuery.width,
              height: mediaQuery.height - (appBar?.preferredSize.height ?? 0),
              child: SproutScrollView(padding: padding, child: child),
            )
          : Padding(
              padding: padding,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [child]),
            );

      return ExitWidget(
        child: SproutScaffold(
          fab: FloatingActionButtonWidget(currentPage),
          appBar: appBar,
          bottomNavigation: !renderNav
              ? null
              : isDesktop
              ? null
              : _getBottomNav(context),
          drawer: !renderNav
              ? null
              : isDesktop
              ? null
              : Drawer(child: SafeArea(child: _buildSideNav(context, isDesktop))),
          child: isDesktop && renderNav ? _getSideNav(context, page, isDesktop) : page,
        ),
      );
    });
  }

  /// Returns the sidenav to render with your given child (as it takes up the body)
  Widget _getSideNav(BuildContext context, Widget? child, bool isDesktop) {
    return Row(
      children: [
        SizedBox(width: 225, child: Material(elevation: 2.0, child: _buildSideNav(context, isDesktop))),
        if (child != null) Expanded(child: child),
      ],
    );
  }

  // This is the widget for the side navigation menu.
  Widget _buildSideNav(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    final userProvider = ServiceLocator.get<UserProvider>();
    final buttons = SproutRouter.pages
        .where((e) => e.canNavigateTo && e.showOnSideNav)
        .mapIndexed((i, page) {
          final elements = _buildNavItem(context, page, i, isDesktop);
          if (page.canNavigateTo) {
            return elements;
          } else {
            return null;
          }
        })
        .nonNulls
        .expand((element) => element)
        .toList();
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (!isDesktop) ...[
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(vertical: 12),
                        child: Image.asset('assets/logo/color-transparent-no-tag.png', height: 64),
                      ),
                      Divider(height: 4, color: theme.colorScheme.secondary),
                    ],
                    ...buttons.map((e) => [e, const Divider(height: 1)]).expand((e) => e),
                  ],
                ),
              ),

              // Settings button
              Padding(
                padding: const EdgeInsets.all(12),
                child: PopupMenuButton<String>(
                  menuPadding: EdgeInsetsGeometry.zero,
                  onSelected: (value) {
                    if (value == 'settings') {
                      final settingsPage = SproutRouter.pages.firstWhereOrNull(
                        (e) => e.label.toLowerCase() == "settings",
                      );
                      if (settingsPage != null) {
                        _navigateToPage(context, settingsPage, isDesktop);
                      }
                    } else if (value == 'logout') {
                      context.read<UserProvider>().logout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'settings',
                      child: ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
                    ),
                  ],
                  child: IgnorePointer(
                    child: FilledButton(
                      onPressed: () {}, // Keep an empty callback to appear enabled
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.person),
                          Expanded(
                            child: Text(
                              userProvider.currentUser?.prettyName ?? "",
                              style: const TextStyle(overflow: TextOverflow.ellipsis),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(width: 6, thickness: 6, color: theme.colorScheme.secondary),
      ],
    );
  }

  /// Navigates to the given page. Intended for the drawer.
  void _navigateToPage(BuildContext context, SproutPage page, bool isDesktop) {
    // Close the drawer on mobile
    if (!isDesktop) Navigator.pop(context);
    SproutNavigator.redirect(page.label);
  }

  /// Builds a navigation item, which can be a regular [ListTile] or an [ExpansionTile] if it has sub-pages.
  List<Widget> _buildNavItem(BuildContext context, SproutPage page, int index, bool isDesktop) {
    final topLevelPageIsSelected = currentPage.label == page.label;
    final tiles = [
      ListTile(
        leading: Icon(page.icon),
        title: Text(page.label, textAlign: TextAlign.center),
        selected: topLevelPageIsSelected,
        onTap: () => _navigateToPage(context, page, isDesktop),
      ),
    ];
    return tiles;
  }

  /// Returns the bottom navigation to display
  Widget _getBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    double fontSize = 8;
    final bottomNavButtons = SproutRouter.pages.where((e) => e.canNavigateTo && e.showOnBottomNav).toList();

    // Place "home" page in the middle
    final homePageIndex = bottomNavButtons.indexWhere((page) => page.label.toLowerCase() == 'home');
    if (homePageIndex != -1) {
      final homePage = bottomNavButtons.removeAt(homePageIndex);
      final middleIndex = (bottomNavButtons.length / 2).ceil();
      bottomNavButtons.insert(middleIndex, homePage);
    }

    final activeIndex = bottomNavButtons.indexWhere((page) => page.label == currentPage.label);

    return BottomNavigationBar(
      currentIndex: activeIndex != -1 ? activeIndex : 0,
      iconSize: 24,
      selectedFontSize: fontSize,
      unselectedFontSize: fontSize,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      unselectedLabelStyle: TextStyle(fontSize: fontSize),
      selectedLabelStyle: TextStyle(fontSize: fontSize),
      onTap: (index) {
        final page = bottomNavButtons[index];
        SproutNavigator.redirect(page.label);
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      selectedItemColor: theme.colorScheme.secondaryContainer,
      unselectedItemColor: theme.colorScheme.onPrimaryContainer,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      items: bottomNavButtons
          .mapIndexed((i, page) {
            if (!page.canNavigateTo) return null;
            return BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.all(4.0), child: Icon(page.icon)),
              label: page.label,
            );
          })
          .nonNulls
          .toList(),
    );
  }
}
