import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

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

  // Custom precise animations mapped to the CSS timeline
  late Animation<double> _drawAnimation;
  late Animation<double> _fillAnimation;
  late Animation<double> _popAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textTranslateAnimation;

  /// Tracks when the introductory animation has finished
  bool _isIntroComplete = false;

  // SVG Paths
  late Path _flowerPath1;
  late Path _flowerPath2;
  late Path _textPath;

  @override
  void initState() {
    super.initState();

    // Parse the SVG paths natively once on init
    _flowerPath1 = parseSvgPathData(
        "m63.9 36.4c-.5-.2-1.1.1-1.3.6-1.3 3.6-4.4 6.2-8.2 6.7-.5.1-.9.6-.9 1.1.1.5.5.9 1 .9h.1c4.5-.6 8.3-3.7 9.8-8 .3-.5.1-1.1-.5-1.3m-26.6 10.6c-.2-.5-.8-.8-1.3-.6s-.8.8-.6 1.3c1.5 4.3 5.3 7.4 9.8 8h.1c.5 0 .9-.4 1-.9s-.3-1.1-.9-1.1c-3.7-.5-6.8-3.1-8.1-6.7");
    _flowerPath2 = parseSvgPathData(
        "m71.5 65.5c-.8-.8-2.1-.8-2.8 0-2 2-7.4 2.9-16.7-.2v-14.2c10.2-.1 18.4-8.4 18.4-18.7v-1.8c0-1.1-.9-2-2-2h-1.8c-9.8 0-17.8 7.6-18.6 17.2-3.4-4.4-8.7-7.2-14.7-7.2h-1.8c-1.1 0-2 .9-2 2v1.8c0 10.2 8.3 18.5 18.5 18.7v3c-10.2-2.5-18.5.8-18.9.9-1 .4-1.5 1.6-1.1 2.6s1.6 1.5 2.6 1.1c.1 0 9-3.5 19.1 0 5.4 1.9 9.5 2.6 12.8 2.6 5 0 7.7-1.7 9.1-3 .7-.8.7-2-.1-2.8m-38-22.8c7.9.1 14.4 6.5 14.5 14.5-7.9-.2-14.4-6.6-14.5-14.5m32.9-10c-.1 7.9-6.5 14.4-14.5 14.5.2-8 6.6-14.4 14.5-14.5");
    _textPath = parseSvgPathData(
        "m13.38.59q-3.1 0-5.14-.57-2.04-0.56-3.27-1.4t-1.89-1.67q-.22-.32-.39-.61-.18-.3-.25-.66-.1-.49-.19-1.28-.1-.8-.03-1.85.03-.44.17-.61.17-.19.56-.29.71-.17 1.85-.3 1.13-0.14 1.62-0.14.51 0 .83.2.32.19.76.66.49.51 1.68 1.3 1.2.8 3.69.8 2.39 0 3.61-1.01 1.22-1 1.22-2.78 0-.95-.57-1.79-.57-.85-2.09-1.69-1.51-.84-4.32-1.77-4.64-1.56-6.69-3.88t-2.05-6.45q0-3.41 1.66-5.71 1.66-2.29 4.59-3.47 2.93-1.17 6.76-1.17 2.96 0 4.9.7 1.94.69 3.01 1.56 1.08.87 1.39 1.41.2.31.26.47t.09.43q.07.76.05 1.68-.03.93-.18 2.1-.07.39-.26.54-.18.12-.54.12-2.37.05-3.66-.24-.52-.12-.69-.25-.17-.12-.44-.39-.39-.46-1.23-1.08-.84-.63-2.7-.63-2.56 0-3.63 1.16-1.08 1.16-1.08 2.6 0 1.71 1.59 2.68 1.58.96 5 2.18 2.86 1 4.91 2.18 2.05 1.17 3.14 3 1.08 1.83 1.08 4.83 0 3.74-1.72 6.2-1.72 2.47-4.69 3.68-2.96 1.21-6.72 1.21m34.18-26.2q3.56 0 5.87 1.6 2.3 1.6 3.44 4.39 1.14 2.8 1.14 6.41 0 3.91-1.34 7.03-1.33 3.13-3.91 4.96-2.59 1.83-6.42 1.83-1.98 0-3.26-.45-1.29-.45-2.05-1.08-.77-.62-1.21-1.13h-.1v10.4q0 .59-.24.9-1.03 1.35-3.01 2.91-.34.24-.61.24-.29 0-.61-.24-1.05-.81-1.77-1.52-.72-.7-1.23-1.39-.25-.31-.25-.9v-30.1q0-.59.25-.91.51-.68 1.23-1.39t1.77-1.51q.32-.25.66-.25.32 0 .66.25 1.03.8 1.76 1.54.73.73 1.29 1.51h.12q.42-.51 1.27-1.24.86-.74 2.43-1.3 1.58-.56 4.12-.56m-3.01 19.99q2.64 0 4.09-1.84 1.46-1.84 1.46-5.33 0-6.59-5.42-6.59-2.3 0-3.4.94t-1.56 1.98v5.3q0 2.37 1.22 3.96 1.22 1.58 3.61 1.58m26.42-16.55v1.81h.09q1.84-5.08 6.6-5.08.61 0 1 .06t.53.11q.37.12.37.56v5.89q0 .75-.88.41-.29-.12-.84-.25-.55-.14-1.53-.14-2.51 0-3.93 1.84-1.41 1.85-1.41 5.02v10.65q0 .73-.31 1.01-.3.28-1.04.28h-5.03q-.73 0-1.03-.28-.31-.28-.31-1.01v-20.46q0-.59.25-.91.51-.68 1.23-1.39t1.77-1.51q.19-.15.39-.2.19-.05.34-.05.34 0 .68.25 2.03 1.59 2.84 2.71.22.29.22.68m24.21 22.78q-6.15 0-9.74-3.27t-3.59-9.74q0-6.64 3.73-9.93 3.72-3.28 9.94-3.28 6.01 0 9.62 3.23 3.62 3.24 3.62 9.54 0 6.57-3.62 10.01-3.61 3.44-9.96 3.44m.25-5.91q2.68 0 4.05-1.67t1.37-5.73q0-3.85-1.38-5.43-1.38-1.57-4.09-1.57-2.61 0-4.12 1.69-1.5 1.7-1.5 5.51 0 3.98 1.43 5.59t4.24 1.61m27.29 5.91q-8.69 0-8.69-10.52l-.03-12.4q0-.59.25-.91 1.02-1.34 3-2.9.34-.25.61-.25.32 0 .61.25 1.05.8 1.77 1.51t1.23 1.39q.25.32.25.91v11.71q0 5.3 4.2 5.3 2.07 0 3.32-1.45 1.24-1.45 1.24-3.94v-11.62q0-.59.25-.91 1.02-1.34 3-2.9.34-.25.61-.25.32 0 .61.25 1.05.8 1.77 1.51t1.23 1.39q.25.32.25.91v21.19q0 .46-.32.79t-.81.33h-3.66q-.39 0-.69-.11-.31-.11-.58-.43l-1.51-1.95h-.17q-.39.56-1.21 1.29-.82.74-2.37 1.27-1.55.54-4.16.54m31.96 0q-8.16 0-8.16-8.47v-11.45h-2.76q-.73 0-1.01-.31-.28-.3-.28-1.03v-3.01q0-.73.28-1.03.28-.31 1.01-.31h2.76v-3.93q0-.59.24-.9 1.03-1.35 3.01-2.91.34-.24.61-.24.29 0 .58.24 1.05.81 1.77 1.51.72.71 1.24 1.4.24.31.24.9v3.93h4.32q.73 0 1.02.31.28.3.28 1.03v3.01q0 .73-.28 1.03-.29.31-1.02.31h-4.32v10.11q0 3.9 2.83 3.9.44 0 .81-.08.37-.09.63-.19.52-.19.72-.14.21.05.38.53l1.42 3.79q.22.61-.29.88-.37.17-1.77.64-1.41.48-4.26.48");

    // Total duration mapped to the HTML's 1.55 seconds timeline
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    );

    // Timeline percentages calculated precisely from CSS intervals:
    _drawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.516, curve: Curves.easeInOutCubic)),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.258, 0.387, curve: Curves.easeInOut)),
    );

    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.580, 0.838)),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.677, 1.0, curve: Curves.easeOut)),
    );

    _textTranslateAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.677, 1.0, curve: Curves.easeOutBack)),
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
                return SizedBox(
                  width: logoWidth,
                  height: logoWidth * (140 / 340),
                  child: CustomPaint(
                    painter: SproutAnimatedPainter(
                      drawProgress: widget.animate ? _drawAnimation.value : 1.0,
                      fillProgress: widget.animate ? _fillAnimation.value : 1.0,
                      popScale: widget.animate ? _popAnimation.value : 1.0,
                      textOpacity: widget.animate ? _textOpacityAnimation.value : 1.0,
                      textTranslateY: widget.animate ? _textTranslateAnimation.value : 0.0,
                      flowerPath1: _flowerPath1,
                      flowerPath2: _flowerPath2,
                      textPath: _textPath,
                      textColor: currentTheme.colorScheme.onSurface,
                    ),
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
                        padding: const EdgeInsets.only(top: 10.0),
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

/// Custom Painter mapping standard CSS commands and drawing natively to standard Flutter Canvas APIs.
class SproutAnimatedPainter extends CustomPainter {
  final double drawProgress;
  final double fillProgress;
  final double popScale;
  final double textOpacity;
  final double textTranslateY;

  final Path flowerPath1;
  final Path flowerPath2;
  final Path textPath;
  final Color textColor;

  SproutAnimatedPainter({
    required this.drawProgress,
    required this.fillProgress,
    required this.popScale,
    required this.textOpacity,
    required this.textTranslateY,
    required this.flowerPath1,
    required this.flowerPath2,
    required this.textPath,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 340;
    final double scaleY = size.height / 140;
    final double scale = math.min(scaleX, scaleY);

    final double dx = (size.width - 340 * scale) / 2;
    final double dy = (size.height - 140 * scale) / 2;

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    canvas.save();
    canvas.translate(135, -45);
    canvas.scale(2.3);

    // Handle Transform Origin -> "Center Box"
    final Rect flowerBounds = flowerPath1.getBounds().expandToInclude(flowerPath2.getBounds());
    final Offset flowerCenter = flowerBounds.center;

    // Apply "Pop" scale locally to the center of the flower
    canvas.translate(flowerCenter.dx, flowerCenter.dy);
    canvas.scale(popScale);
    canvas.translate(-flowerCenter.dx, -flowerCenter.dy);

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF38bdf8).withOpacity((1.0 - fillProgress).clamp(0.0, 1.0))
      ..strokeWidth = 0.4;

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF116383).withOpacity(fillProgress);

    if (drawProgress > 0) {
      final Path drawnPath1 = _extractPartialPath(flowerPath1, drawProgress);
      final Path drawnPath2 = _extractPartialPath(flowerPath2, drawProgress);

      canvas.drawPath(drawnPath1, strokePaint);
      canvas.drawPath(drawnPath2, strokePaint);

      if (fillProgress > 0) {
        canvas.drawPath(flowerPath1, fillPaint);
        canvas.drawPath(flowerPath2, fillPaint);
      }
    }
    canvas.restore();

    canvas.save();
    canvas.translate(32, 95);
    canvas.translate(0, textTranslateY);

    final Paint textFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = textColor.withOpacity(textOpacity);

    if (textOpacity > 0) {
      canvas.drawPath(textPath, textFillPaint);
    }
    canvas.restore();
  }

  Path _extractPartialPath(Path path, double progress) {
    if (progress >= 1.0) return path;

    final Path extraction = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      extraction.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }
    return extraction;
  }

  @override
  bool shouldRepaint(covariant SproutAnimatedPainter oldDelegate) {
    return drawProgress != oldDelegate.drawProgress ||
        fillProgress != oldDelegate.fillProgress ||
        popScale != oldDelegate.popScale ||
        textOpacity != oldDelegate.textOpacity ||
        textTranslateY != oldDelegate.textTranslateY;
  }
}
