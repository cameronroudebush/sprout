import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A wrapper around your main content to help provide child size restrictions and helpful functionality
class SproutRouteWrapper extends ConsumerWidget {
  final Widget child;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  const SproutRouteWrapper(
      {super.key,
      required this.child,
      this.floatingActionButton,
      this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 8)});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(child: Container(constraints: BoxConstraints(maxWidth: 1024), padding: padding, child: child));
  }
}
