import 'package:flutter/material.dart';

/// Compact label showing which model generated an AI response.
class ChatModelIndicator extends StatelessWidget {
  final String? model;
  final Color? color;

  /// Hides the actual model text
  final bool compact;

  /// False renders text before, true renders text after
  final bool textAfter;

  const ChatModelIndicator({super.key, required this.model, this.color, this.compact = false, this.textAfter = true});

  @override
  Widget build(BuildContext context) {
    final value = model?.trim();
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    final foreground = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final text = Flexible(
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, color: foreground),
      ),
    );
    return Tooltip(
      message: 'Model used: $value',
      preferBelow: false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (!compact && !textAfter) text,
          Icon(Icons.memory_outlined, color: foreground),
          if (!compact && textAfter) text,
        ],
      ),
    );
  }
}
