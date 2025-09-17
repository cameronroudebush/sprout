import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/core/models/page.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/router.dart';
import 'package:sprout/core/widgets/app_bar.dart';
import 'package:sprout/core/widgets/exit.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/core/widgets/scroll.dart';
import 'package:sprout/core/widgets/text.dart';

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

    return SproutLayoutBuilder((isDesktop, context) {
      /// The app bar we want, if necessary
      final appBar = !renderAppBar
          ? null
          : SproutAppBar(
              screenHeight: mediaQuery.height,
              buttonBuilder: currentPage.buttonBuilder,
              useFullLogo: currentPage.useFullLogo,
            );

      // The page to render, considering scroll-ability
      final page = currentPage.scrollWrapper
          ? SizedBox(
              width: mediaQuery.width,
              height: mediaQuery.height - (appBar?.preferredSize.height ?? 0),
              child: SproutScrollView(child: child),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [child]),
            );

      return ExitWidget(
        child: SproutScaffold(
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
    final authProvider = ServiceLocator.get<AuthProvider>();
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
                padding: EdgeInsetsGeometry.all(12),
                child: FilledButton(
                  onPressed: () {
                    final settingsPage = SproutRouter.pages.firstWhereOrNull(
                      (e) => e.label.toLowerCase() == "settings",
                    );
                    if (settingsPage != null) {
                      _navigateToPage(context, settingsPage, isDesktop);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 12,
                    children: [
                      Icon(Icons.settings, size: 36),
                      TextWidget(referenceSize: 1.5, text: authProvider.currentUser?.prettyName ?? ""),
                      const SizedBox.shrink(),
                    ],
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
        title: TextWidget(text: page.label),
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
    return BottomNavigationBar(
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
            final isSelected = page.label == currentPage.label;
            return BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  page.icon,
                  color: isSelected ? theme.colorScheme.secondaryContainer : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              label: page.label,
            );
          })
          .nonNulls
          .toList(),
    );
  }
}
