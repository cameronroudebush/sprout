import 'package:flutter/material.dart';

/// A generic scroll view element that provides some generic styling for Sprout
class SproutScrollView extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  /// If we should constrain the size of the child
  final bool constrain;

  const SproutScrollView({
    super.key,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.constrain = true,
  });

  @override
  Widget build(BuildContext context) {
    if (constrain) {
      return SingleChildScrollView(
        padding: padding,
        child: Center(
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1024), child: child),
        ),
      );
    }
    return SingleChildScrollView(padding: padding, child: child);
  }
}
