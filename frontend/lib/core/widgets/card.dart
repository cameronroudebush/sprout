import 'package:flutter/material.dart';

/// A generic card for use in sprout that better aligns the default styling
class SproutCard extends StatelessWidget {
  final Widget? child;
  final double? widthMultiplier;
  final bool applySizedBox;
  final double? height;

  const SproutCard({super.key, this.child, this.widthMultiplier, this.applySizedBox = true, this.height});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: child,
      ),
    );
    return applySizedBox
        ? SizedBox(width: mediaQuery.size.width * (widthMultiplier ?? 1), height: height, child: content)
        : content;
  }
}
