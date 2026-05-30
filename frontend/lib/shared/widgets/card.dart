import 'package:flutter/material.dart';

/// A generic card for use in sprout that utilizes elevation instead of flat borders
/// for a clean, dimensional aesthetic.
class SproutCard extends StatelessWidget {
  final Widget? child;
  final double? widthMultiplier;
  final bool applySizedBox;
  final double? height;
  final Color? bgColor;
  final double? elevation;
  final bool clip;

  const SproutCard({
    super.key,
    this.child,
    this.widthMultiplier,
    this.applySizedBox = true,
    this.height,
    this.bgColor,
    this.elevation,
    this.clip = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final card = Card(
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );

    final content = clip ? ClipRRect(borderRadius: BorderRadius.circular(12), child: card) : card;
    return applySizedBox
        ? SizedBox(width: mediaQuery.size.width * (widthMultiplier ?? 1), height: height, child: content)
        : content;
  }
}
