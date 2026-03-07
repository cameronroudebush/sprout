import 'package:flutter/material.dart';

/// A generic card for use in sprout that better aligns the default styling
class SproutCard extends StatelessWidget {
  final Widget? child;
  final double? widthMultiplier;
  final bool applySizedBox;
  final double? height;
  final Color? bgColor;
  final bool clip;

  const SproutCard({
    super.key,
    this.child,
    this.widthMultiplier,
    this.applySizedBox = true,
    this.height,
    this.bgColor,
    this.clip = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isAbsoluteDark = Theme.of(context).scaffoldBackgroundColor == Colors.black;

    final card = Card(
      elevation: isAbsoluteDark ? 0 : 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Matched to your theme's 12.0
        side: isAbsoluteDark ? BorderSide(color: Colors.white.withOpacity(0.12), width: 1) : BorderSide.none,
      ),
      color: bgColor ?? (isAbsoluteDark ? const Color(0xFF121212) : null),
      child: child,
    );

    final content = clip ? ClipRRect(borderRadius: BorderRadius.circular(12), child: card) : card;
    return applySizedBox
        ? SizedBox(width: mediaQuery.size.width * (widthMultiplier ?? 1), height: height, child: content)
        : content;
  }
}
