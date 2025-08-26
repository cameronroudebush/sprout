import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A generic scaffold component used to wrap everything we display. This also includes
///   the display capability for the sidenav.
class SproutScaffold extends StatelessWidget {
  final Widget? child;

  /// App bar to display for our scaffold
  final PreferredSizeWidget? appBar;

  /// Bottom navigation to display
  final Widget? bottomNavigation;

  /// Drawer to display a sidenav
  final Widget? drawer;

  const SproutScaffold({super.key, required this.child, this.appBar, this.bottomNavigation, this.drawer});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(systemNavigationBarColor: const Color(0xFF001e2c)),
      child: Scaffold(appBar: appBar, body: child, bottomNavigationBar: bottomNavigation, drawer: drawer),
    );
  }
}
