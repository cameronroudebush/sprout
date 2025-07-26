import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/overview.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/home.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/widgets/app_bar.dart';
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

  final List<Map<String, dynamic>> _pages = const <Map<String, dynamic>>[
    {'page': HomePage(), 'icon': Icons.home, 'label': 'Home'},
    {'page': AccountOverviewPage(), 'icon': Icons.account_balance, 'label': 'Accounts'},
    {'page': TransactionsOverviewPage(), 'icon': Icons.receipt, 'label': 'Transactions'},
    {'page': UserPage(), 'icon': Icons.account_circle, 'label': 'User'},
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
        final screenHeight = MediaQuery.of(context).size.height;
        return Scaffold(
          appBar: SproutAppBar(screenHeight: screenHeight, currentPage: _pages[_currentIndex]['label']),
          body: Center(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1024),
                child: SingleChildScrollView(child: _pages[_currentIndex]['page']),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index; // Update the index
              });
            },
            backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface,
            type: BottomNavigationBarType.fixed,
            enableFeedback: true,
            items: _pages
                .map((pageData) => BottomNavigationBarItem(icon: Icon(pageData['icon']), label: pageData['label']))
                .toList(),
          ),
        );
      },
    );
  }
}
