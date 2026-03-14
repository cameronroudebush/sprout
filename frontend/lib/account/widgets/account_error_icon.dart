import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/tooltip.dart';

/// An icon that is intended to just display an error if an account has one
class SproutErrorIcon extends StatefulWidget {
  final bool hasError;
  final double size;
  final String? message;

  const SproutErrorIcon({super.key, required this.hasError, this.size = 18.0, this.message});

  @override
  State<SproutErrorIcon> createState() => _SproutErrorIconState();
}

class _SproutErrorIconState extends State<SproutErrorIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    // Creates a pulsing scale effect
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Creates a subtle side-to-side wobble
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.hasError) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SproutErrorIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart or stop the animation if the error state toggles
    if (widget.hasError && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.hasError && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasError) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return SproutTooltip(
      message: widget.message ?? "Connection error",
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.error, color: theme.colorScheme.error, size: widget.size),
              ),
            ),
          );
        },
      ),
    );
  }
}
