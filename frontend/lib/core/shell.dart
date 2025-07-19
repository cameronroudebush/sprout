import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/home.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/setup/setup.dart';
import 'package:sprout/transaction/overview.dart';
import 'package:sprout/user/user.dart';

/// This class defines the shell that wraps all pages that are displayed for sprout
class SproutAppShell extends StatefulWidget {
  final bool isSetup;
  final VoidCallback? onSetupSuccess;
  const SproutAppShell({super.key, this.isSetup = false, this.onSetupSuccess});

  @override
  State<SproutAppShell> createState() => _SproutAppShellState();
}

class _SproutAppShellState extends State<SproutAppShell> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = const <Map<String, dynamic>>[
    {'page': HomePage(), 'icon': Icons.home, 'label': 'Home'},
    {'page': TransactionsOverviewPage(), 'icon': Icons.receipt, 'label': 'Transactions'},
    {'page': UserPage(), 'icon': Icons.account_circle, 'label': 'Account'},
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
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: MediaQuery.of(context).size.height * .075,
            scrolledUnderElevation: 0,
            title: Image.asset(
              'assets/logo/color-transparent-no-tag.png',
              width: MediaQuery.of(context).size.height * .2,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            centerTitle: true,
            elevation: 0, // Remove shadow for a flat design
            backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(8.0),
              child: Container(color: Theme.of(context).colorScheme.secondary.withAlpha(100), height: 8.0),
            ),
          ),
          body: widget.isSetup
              ? SetupPage(onSetupSuccess: widget.onSetupSuccess!)
              : Center(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1024),
                      child: SingleChildScrollView(child: _pages[_currentIndex]['page']),
                    ),
                  ),
                ),
          bottomNavigationBar: widget.isSetup
              ? null
              : BottomNavigationBar(
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
                      .map(
                        (pageData) => BottomNavigationBarItem(icon: Icon(pageData['icon']), label: pageData['label']),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}
