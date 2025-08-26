import 'package:flutter/material.dart';
import 'package:sprout/account/overview.dart';
import 'package:sprout/core/home.dart';
import 'package:sprout/core/models/page.dart';
import 'package:sprout/core/widgets/app_bar.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/holding/overview.dart';
import 'package:sprout/transaction/overview.dart';
import 'package:sprout/user/user.dart';

/// A wrapper around the scaffold that renders the navigation selection options as well as the current page
class SproutNavScaffold extends StatefulWidget {
  const SproutNavScaffold({super.key});

  /// All pages available to the app for navigating between
  static List<SproutPage> pages = const [
    SproutPage(page: HomePage(), icon: Icons.home, label: 'Home'),
    SproutPage(
      page: AccountsOverview(),
      icon: Icons.account_balance,
      label: 'Accounts',
      subPages: [SproutPage(page: HoldingsOverview(), icon: Icons.stacked_line_chart_rounded, label: 'Holdings')],
    ),
    SproutPage(page: TransactionsOverviewPage(), icon: Icons.receipt, label: 'Transactions'),
    SproutPage(page: UserPage(), icon: Icons.settings, label: 'Settings'),
  ];

  @override
  State<SproutNavScaffold> createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<SproutNavScaffold> {
  SproutPage _currentPage = SproutNavScaffold.pages[0];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double desktopBreakpoint = 700.0;
        final isDesktop = constraints.maxWidth >= desktopBreakpoint;

        final totalPages = SproutNavScaffold.pages
            .map((e) {
              final pages = [e];
              if (e.subPages != null) pages.addAll(e.subPages!);
              return pages;
            })
            .expand((e) => e)
            .toList();
        final currentPageIndex = totalPages.indexOf(_currentPage);
        final child = IndexedStack(index: currentPageIndex, children: totalPages.map((e) => e.page).toList());

        return SproutScaffold(
          appBar: SproutAppBar(screenHeight: screenHeight),
          bottomNavigation: isDesktop ? null : _getBottomNav(context),
          drawer: isDesktop ? null : Drawer(child: _buildSideNav(context, isDesktop)),
          child: isDesktop ? _getSideNav(context, child, isDesktop) : child,
        );
      },
    );
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
    final buttons = SproutNavScaffold.pages
        .map((page) => _buildNavItem(page))
        .toList()
        .expand((element) => element)
        .toList();
    return Row(
      children: [
        Expanded(
          // ListView.separated is the best way to build a list with dividers between items.
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
        VerticalDivider(width: 6, thickness: 6, color: theme.colorScheme.secondary),
      ],
    );
  }

  /// Builds a navigation item, which can be a regular [ListTile] or an [ExpansionTile] if it has sub-pages.
  List<Widget> _buildNavItem(SproutPage page) {
    void onSet(SproutPage page) => setState(() {
      _currentPage = page;
    });
    final tiles = [
      ListTile(
        leading: Icon(page.icon),
        title: TextWidget(text: page.label),
        selected: _currentPage.label == page.label,
        onTap: () => onSet(page),
      ),
    ];

    // If page has sub-pages, return them with my current
    if (page.subPages?.isNotEmpty ?? false) {
      tiles.addAll(
        // Include sub pages
        page.subPages!.map((subPage) {
          return ListTile(
            contentPadding: const EdgeInsets.only(left: 30.0),
            title: TextWidget(text: subPage.label),
            leading: Icon(subPage.icon),
            selected: _currentPage.label == subPage.label,
            onTap: () => onSet(subPage),
          );
        }),
      );
    }
    return tiles;
  }

  /// Gets the index of the top-level page that is currently selected, or contains the selected sub-page.
  int _getTopLevelPageIndex() {
    final topLevelIndex = SproutNavScaffold.pages.indexWhere((p) {
      // Is the current page this top-level page?
      if (p.label == _currentPage.label) return true;
      // Is the current page a sub-page of this top-level page?
      if (p.subPages?.any((sp) => sp.label == _currentPage.label) ?? false) {
        return true;
      }
      return false;
    });

    return topLevelIndex > -1 ? topLevelIndex : 0;
  }

  /// Returns the bottom navigation to display
  Widget _getBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final currentTopLevelIndex = _getTopLevelPageIndex();
    double fontSize = 8;
    return BottomNavigationBar(
      iconSize: 24,
      selectedFontSize: fontSize,
      unselectedFontSize: fontSize,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      unselectedLabelStyle: TextStyle(fontSize: fontSize),
      selectedLabelStyle: TextStyle(fontSize: fontSize),
      currentIndex: currentTopLevelIndex,
      onTap: (index) {
        final selectedTopLevelPage = SproutNavScaffold.pages[index];
        setState(() {
          _currentPage = selectedTopLevelPage;
        });
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      selectedItemColor: theme.colorScheme.secondaryContainer,
      unselectedItemColor: theme.colorScheme.onPrimaryContainer,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      items: SproutNavScaffold.pages.asMap().entries.map((entry) {
        final isSelected = entry.key == currentTopLevelIndex;
        final pageData = entry.value;
        return BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              pageData.icon,
              color: isSelected ? theme.colorScheme.secondaryContainer : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          label: pageData.label,
        );
      }).toList(),
    );
  }

  // /// An empty bar that shows the page name and the sprout icon.
  // Widget _blankBar(BuildContext context, Widget? leadingContent) {
  //   return Row(
  //     children: [
  //       // The leading content on the left.
  //       Expanded(child: leadingContent ?? const SizedBox.shrink()),
  //       // The page title in the center.
  //       TextWidget(
  //         referenceSize: 2,
  //         text: currentPage?.label ?? "",
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       // The icon on the right, aligned properly.
  //       Expanded(
  //         child: Align(
  //           alignment: Alignment.centerRight,
  //           child: Image.asset(
  //             'assets/icon/favicon-color.png',
  //             height: preferredSize.height * 0.85,
  //             fit: BoxFit.contain,
  //             filterQuality: FilterQuality.high,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // /// Renders the content for the "Accounts" page app bar.
  // Widget _accountPage(BuildContext context) {
  //   return _blankBar(
  //     context,
  //     Align(
  //       alignment: Alignment.centerLeft,
  //       child: SproutTooltip(
  //         message: "Add an account",
  //         child: ButtonWidget(
  //           icon: Icons.add,
  //           height: screenHeight * .035,
  //           minSize: MediaQuery.of(context).size.width * .1,
  //           onPressed: () async {
  //             // Open the add account dialog
  //             await showDialog(context: context, builder: (_) => const AddAccountDialog());
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // /// Renders the content for the "Home" and "Setup" page app bars.
  // Widget _homeContent(BuildContext context) {
  //   return Image.asset(
  //     'assets/logo/color-transparent-no-tag.png',
  //     width: screenHeight * .12,
  //     fit: BoxFit.contain,
  //     filterQuality: FilterQuality.high,
  //   );
  // }
}
