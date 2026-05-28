import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/logo.dart';
import 'package:sprout/theme/absolute_dark.dart';
// Import your SproutFullLogo widget path here

class SproutLoadingIndicator extends StatefulWidget {
  final String? message;
  final bool animate;

  const SproutLoadingIndicator({
    super.key,
    this.message,
    this.animate = true,
  });

  @override
  State<SproutLoadingIndicator> createState() => _SproutLoadingIndicatorState();
}

class _SproutLoadingIndicatorState extends State<SproutLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _revealAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // If animate is false, jump straight to the end frame immediately
    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant SproutLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle dynamic changes if necessary
    if (!widget.animate && _animationController.value != 1.0) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoWidth = (size.width * 0.65).clamp(240.0, 480.0);

    return Scaffold(
      backgroundColor: absoluteDarkTheme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: ClipRect(
                    clipper: LeftToRightClipper(progress: _revealAnimation.value),
                    child: SproutLogo(logoWidth),
                  ),
                );
              },
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      widget.message!,
                      style: absoluteDarkTheme.textTheme.titleMedium?.copyWith(
                        color: absoluteDarkTheme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LeftToRightClipper extends CustomClipper<Rect> {
  final double progress;
  LeftToRightClipper({required this.progress});

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * progress, size.height);

  @override
  bool shouldReclip(covariant LeftToRightClipper oldClipper) => oldClipper.progress != progress;
}
