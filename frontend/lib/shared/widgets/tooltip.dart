import 'package:flutter/material.dart';

/// A generic tooltip class that provides sprout styling
class SproutTooltip extends StatelessWidget {
  /// The text to display
  final String message;

  /// The child to wrap the tooltip with
  final Widget child;

  final TextStyle? style;

  const SproutTooltip({super.key, required this.message, required this.child, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.secondary;
    final completeTextStyle = TextStyle(color: theme.textTheme.bodyLarge!.color, backgroundColor: bgColor).merge(style);
    return Tooltip(
      textStyle: completeTextStyle,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      message: message,
      child: child,
    );
  }
}
