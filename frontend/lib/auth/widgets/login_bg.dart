import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// Represents a rendered particle that can grab onto other particles
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  int colorIndex;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.colorIndex,
  });
}

/// Represents a text item floating in the background
class FloatingTextItem {
  double x;
  double y;
  double vx;
  final TextPainter painter;

  FloatingTextItem({
    required this.x,
    required this.y,
    required this.vx,
    required this.painter,
  });
}

/// A widget that renders the background image to show with the login page
class LoginBackgroundWidget extends StatefulWidget {
  // Random financial related text to show floating around
  final List<String> textOptions;

  /// If we should render the text options floating around
  final bool showText;

  const LoginBackgroundWidget(
      {super.key,
      this.showText = true,
      this.textOptions = const [
        "Compound Interest",
        "Asset Allocation",
        "Dividend Yield",
        "Wealth Management",
        "Portfolio Growth",
        "Net Asset Value",
        "Capital Gains",
        "Risk Mitigation",
        "Fiscal Discipline",
        "Equity Multiplier",
        "Liquidity Ratio",
        "Amortization Schedule",
        "Market Cap Strategy",
        "Yield Curve Optimization",
        "Diversification",
        "Passive Income Streams",
        "Financial Freedom",
        "Cash Flow Management",
        "Smart Budgeting",
        "Future Value Target",
        "Annuity Growth",
        "Principal Protection",
      ]});

  @override
  State<LoginBackgroundWidget> createState() => _LoginBackgroundWidgetState();
}

class _LoginBackgroundWidgetState extends State<LoginBackgroundWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final List<FloatingTextItem> _texts = [];
  Offset? _pointerPosition;
  Size _lastSize = Size.zero;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..addListener(_updatePhysics);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initElements(Size size, Color primaryColor, bool isDesktop) {
    _particles.clear();
    _texts.clear();
    int particleCount = ((size.width * size.height) / (isDesktop ? 10000 : 8000)).floor();
    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          vx: (_random.nextDouble() - 0.5) * 1.0,
          vy: (_random.nextDouble() - 0.5) * 1.0,
          radius: _random.nextDouble() * 2 + 1,
          colorIndex: _random.nextInt(2),
        ),
      );
    }

    if (widget.textOptions.isEmpty || !widget.showText) return;
    int textCount = ((size.width * size.height) / 80000).floor();
    // Create a unique, shuffled list from textOptions
    final List<String> uniquePool = List.from(widget.textOptions)..shuffle(_random);
    // Ensure we don't try to pull more unique items than available in the pool
    final int maxUniqueCount = min(textCount, uniquePool.length);

    for (int i = 0; i < maxUniqueCount; i++) {
      // Pull sequentially from our already shuffled, unique pool
      String text = uniquePool[i];
      double fontSize = _random.nextDouble() * 12 + 12;
      double opacity = _random.nextDouble() * 0.15 + 0.05;
      double vx = _random.nextDouble() * 0.4 + 0.1;
      if (_random.nextBool()) vx *= -1;

      Color color;
      if (text.contains('+')) {
        color = const Color(0xFF10B981).withOpacity(opacity);
      } else if (text.contains('-')) {
        color = const Color(0xFFEF4444).withOpacity(opacity);
      } else {
        color = primaryColor.withOpacity(opacity);
      }

      TextPainter tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      _texts.add(
        FloatingTextItem(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          vx: vx,
          painter: tp,
        ),
      );
    }
  }

  void _updatePhysics() {
    if (_lastSize.isEmpty) return;

    for (var text in _texts) {
      text.x += text.vx;
      if (text.x > _lastSize.width + 200) {
        text.x = -200;
      } else if (text.x < -200) {
        text.x = _lastSize.width + 200;
      }
    }

    for (var particle in _particles) {
      particle.x += particle.vx;
      particle.y += particle.vy;

      if (particle.x < 0 || particle.x > _lastSize.width) particle.vx *= -1;
      if (particle.y < 0 || particle.y > _lastSize.height) particle.vy *= -1;

      if (_pointerPosition != null) {
        double dx = _pointerPosition!.dx - particle.x;
        double dy = _pointerPosition!.dy - particle.y;
        double distSq = dx * dx + dy * dy;

        if (distSq < 22500) {
          double distance = sqrt(distSq);
          double forceDirectionX = dx / distance;
          double forceDirectionY = dy / distance;
          double force = (150 - distance) / 150;

          particle.x += forceDirectionX * force * 1.5;
          particle.y += forceDirectionY * force * 1.5;
        }
      }
    }
  }

  void _onPointerHover(PointerEvent event) {
    _pointerPosition = event.localPosition;
  }

  void _onPointerExit(PointerEvent event) {
    _pointerPosition = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _pointerPosition = details.localPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    _pointerPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bgColor = theme.scaffoldBackgroundColor;
    final primaryColor = colors.primary;
    final secondaryColor = colors.secondary;
    final palette = [primaryColor, secondaryColor];

    return SproutLayoutBuilder((isDesktop, ctx, ctr) {
      return ClipRect(
        child: ColoredBox(
          color: bgColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              Size currentSize = Size(constraints.maxWidth, constraints.maxHeight);
              if (_lastSize != currentSize) {
                _lastSize = currentSize;
                _initElements(currentSize, primaryColor, isDesktop);
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  MouseRegion(
                    onHover: _onPointerHover,
                    onExit: _onPointerExit,
                    child: GestureDetector(
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: _ParticlePainter(
                          particles: _particles,
                          texts: _texts,
                          animation: _controller,
                          palette: palette,
                          lineColor: primaryColor,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.5,
                          colors: [
                            Colors.transparent,
                            bgColor.withOpacity(0.85),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final List<FloatingTextItem> texts;
  final Animation<double> animation;
  final List<Color> palette;
  final Color lineColor;
  final Paint _particlePaint = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  _ParticlePainter({
    required this.particles,
    required this.texts,
    required this.animation,
    required this.palette,
    required this.lineColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var textItem in texts) {
      textItem.painter.paint(canvas, Offset(textItem.x, textItem.y));
    }

    for (int i = 0; i < particles.length; i++) {
      var p1 = particles[i];
      _particlePaint.color = palette[p1.colorIndex % palette.length];
      canvas.drawCircle(Offset(p1.x, p1.y), p1.radius, _particlePaint);

      for (int j = i + 1; j < particles.length; j++) {
        var p2 = particles[j];
        double dx = p1.x - p2.x;
        double dy = p1.y - p2.y;
        double distSq = dx * dx + dy * dy;

        if (distSq < 12100) {
          double distance = sqrt(distSq);
          double opacity = 1 - (distance / 110);
          _linePaint.color = lineColor.withOpacity(opacity * 0.5);
          canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), _linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
