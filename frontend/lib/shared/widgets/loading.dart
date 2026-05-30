import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/logo.dart';

/// A loading indicator used for when Sprout is still setting up the app
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

  /// Tracks when the introductory wipe-in has finished
  bool _isIntroComplete = false;

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

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isIntroComplete) {
        setState(() {
          _isIntroComplete = true;
        });
      }
    });

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
      _isIntroComplete = true;
    }
  }

  @override
  void didUpdateWidget(covariant SproutLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate && !_isIntroComplete) {
      _animationController.stop();
      setState(() {
        _isIntroComplete = true;
      });
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

    final currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
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
                    clipper: LeftToRightClipper(
                      progress: _isIntroComplete ? 1.0 : _revealAnimation.value,
                    ),
                    child: SproutLogo(logoWidth),
                  ),
                );
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _isIntroComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: _isIntroComplete
                    ? Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: SizedBox(
                          width: logoWidth * 0.8,
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                backgroundColor: currentTheme.colorScheme.surfaceContainerHighest,
                                color: currentTheme.colorScheme.primary,
                              ),
                              if (widget.message != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  widget.message!,
                                  style: currentTheme.textTheme.titleMedium?.copyWith(
                                    color: currentTheme.colorScheme.onSurfaceVariant,
                                    letterSpacing: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget that allows us to show our logo from left to right
class LeftToRightClipper extends CustomClipper<Rect> {
  final double progress;
  LeftToRightClipper({required this.progress});

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * progress, size.height);

  @override
  bool shouldReclip(covariant LeftToRightClipper oldClipper) => oldClipper.progress != progress;
}
