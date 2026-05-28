import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Defines the layout constraint presets for application route windows.
enum SproutRouteSize {
  small(768.0),
  auto(1024.0),
  large(1540.0);

  final double maxWidth;
  const SproutRouteSize(this.maxWidth);
}

/// A wrapper around main content to help provide child size restrictions and helpful functionality
class SproutRouteWrapper extends ConsumerWidget {
  final Widget child;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final SproutRouteSize size;

  const SproutRouteWrapper({
    super.key,
    required this.child,
    this.floatingActionButton,
    this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 8),
    this.size = SproutRouteSize.auto,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: size.maxWidth),
        padding: padding,
        child: child,
      ),
    );
  }
}
