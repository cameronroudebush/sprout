import 'package:flutter/material.dart';

/// A generic card for use in sprout that better aligns the default styling
class SproutCard extends StatelessWidget {
  final Widget? child;

  const SproutCard({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SizedBox(
      width: mediaQuery.size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: child,
        ),
      ),
    );
  }
}
