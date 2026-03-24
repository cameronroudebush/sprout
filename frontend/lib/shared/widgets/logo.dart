import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A reusable widget that just renders the Sprout logo
class SproutLogo extends StatelessWidget {
  final double width;
  const SproutLogo(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/color-transparent-no-tag.svg',
      width: width,
      fit: BoxFit.contain,
    );
  }
}
