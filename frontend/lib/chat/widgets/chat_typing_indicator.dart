import 'package:flutter/material.dart';

/// A widget that provides an indication for when the LLM is thinking
class TypingIndicator extends StatefulWidget {
  final Color? color;
  final double dotSize;

  const TypingIndicator({super.key, this.color, this.dotSize = 8.0});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double begin = index * 0.2;
            final double end = begin + 0.4;

            final double opacity = CurvedAnimation(
              parent: _controller,
              curve: Interval(begin, end.clamp(0.0, 1.0), curve: Curves.easeInOut),
            ).value;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: widget.dotSize,
              width: widget.dotSize,
              decoration: BoxDecoration(
                color: (widget.color ?? Colors.grey).withOpacity(0.3 + (0.7 * opacity)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
