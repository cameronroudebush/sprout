import 'package:flutter/material.dart';

/// A class that you can use to wrap your content in a build and determine if this is a mobile or desktop display
class SproutLayoutBuilder extends StatelessWidget {
  /// How many pixels anything over this is considered a "desktop" display
  static final desktopBreakpoint = 1200;

  /// Function to call with our information
  final Widget Function(bool isDesktop, BuildContext context, BoxConstraints constraints) builder;

  const SproutLayoutBuilder(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= desktopBreakpoint;
        return builder(isDesktop, context, constraints);
      },
    );
  }
}
