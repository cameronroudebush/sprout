import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A reusable widget that just renders the Sprout icon
class SproutIcon extends StatelessWidget {
  final double width;
  const SproutIcon(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icon/favicon-color.svg',
      width: width,
      fit: BoxFit.contain,
    );
  }
}
