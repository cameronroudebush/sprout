import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/overview.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/home.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/widgets/scaffold.dart';
import 'package:sprout/holding/overview.dart';
import 'package:sprout/transaction/overview.dart';
import 'package:sprout/user/user.dart';

/// This class defines the shell that wraps all pages that are displayed for sprout
class SproutAppShell extends StatefulWidget {
  final VoidCallback? onSetupSuccess;
  const SproutAppShell({super.key, this.onSetupSuccess});

  @override
  State<SproutAppShell> createState() => _SproutAppShellState();
}

class _SproutAppShellState extends State<SproutAppShell> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _pages = const <Map<String, dynamic>>[
    {'page': HomePage(), 'icon': Icons.home, 'label': 'Home'},
    {'page': AccountsOverview(), 'icon': Icons.account_balance, 'label': 'Accounts'},
    {'page': TransactionsOverviewPage(), 'icon': Icons.receipt, 'label': 'Transactions'},
    {'page': HoldingsOverview(), 'icon': Icons.stacked_line_chart_rounded, 'label': 'Stocks'},
    {'page': UserPage(), 'icon': Icons.account_circle, 'label': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    BaseProvider.updateAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        if (_scrollController.positions.isNotEmpty) _scrollController.jumpTo(0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return SproutScaffold(
              applyAppBar: true,
              currentPage: _pages[_currentIndex]['label'],
              bottomNav: _getBottomNavBar(isMobile, context),
              child: Center(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1024),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                        child: _pages[_currentIndex]['page'],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _getBottomNavBar(bool isMobile, BuildContext context) {
    final theme = Theme.of(context);
    double fontSize = isMobile ? 8 : 12;
    return BottomNavigationBar(
      iconSize: isMobile ? 24 : 28,
      selectedFontSize: fontSize,
      unselectedFontSize: fontSize,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      unselectedLabelStyle: TextStyle(fontSize: fontSize),
      selectedLabelStyle: TextStyle(fontSize: fontSize),
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index; // Update the index
        });
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      selectedItemColor: theme.colorScheme.secondaryContainer,
      unselectedItemColor: theme.colorScheme.onPrimaryContainer,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      items: _pages.map((pageData) {
        final isSelected = pageData['label'] == _pages[_currentIndex]['label'];
        return BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(
              pageData['icon'],
              color: isSelected ? theme.colorScheme.secondaryContainer : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          label: pageData['label'],
        );
      }).toList(),
    );
  }
}
