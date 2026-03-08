import 'package:flutter/material.dart';

/// A generic card for use in sprout that better aligns the default styling
class SproutCard extends StatelessWidget {
  final Widget? child;
  final double? widthMultiplier;
  final bool applySizedBox;
  final double? height;
  final Color? bgColor;
  final Color? borderColor;
  final bool clip;

  const SproutCard({
    super.key,
    this.child,
    this.widthMultiplier,
    this.applySizedBox = true,
    this.height,
    this.bgColor,
    this.borderColor,
    this.clip = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final card = Card(
      color: bgColor ?? theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: borderColor ?? theme.dividerColor, width: 1),
      ),
      child: child,
    );

    final content = clip ? ClipRRect(borderRadius: BorderRadius.circular(12), child: card) : card;
    return applySizedBox
        ? SizedBox(width: mediaQuery.size.width * (widthMultiplier ?? 1), height: height, child: content)
        : content;
  }
}
