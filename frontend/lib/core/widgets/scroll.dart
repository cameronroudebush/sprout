import 'package:flutter/material.dart';
import 'package:sprout/core/theme.dart';

/// A generic scroll view element that provides some generic styling for Sprout
class SproutScrollView extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  /// A scroll controller to use for this view
  final ScrollController? scrollController;

  /// If we should constrain the size of the child
  final bool constrain;

  const SproutScrollView({
    super.key,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.constrain = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (constrain) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppTheme.maxDesktopSize),
            child: child,
          ),
        ),
      );
    }
    return SingleChildScrollView(padding: padding, child: child);
  }
}
