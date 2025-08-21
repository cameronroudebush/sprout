import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprout/core/widgets/app_bar.dart';

/// A generic scaffold component used to wrap everything we display
class SproutScaffold extends StatelessWidget {
  final Widget child;

  /// If we should render the top app bar
  final bool applyAppBar;

  /// The current page to display in the app bar if we wish
  final String? currentPage;

  /// A bottom navigation to render on our scaffold
  final Widget? bottomNav;

  const SproutScaffold({super.key, required this.child, this.applyAppBar = false, this.currentPage, this.bottomNav});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: const Color(0xFF001e2c),
      ),
      child: Scaffold(
        appBar: applyAppBar ? SproutAppBar(screenHeight: screenHeight, currentPage: currentPage) : null,
        body: SafeArea(child: child),
        bottomNavigationBar: bottomNav,
      ),
    );
  }
}
