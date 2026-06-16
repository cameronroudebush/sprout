import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sprout/shared/models/extensions/color_extensions.dart';

/// A widget that renders the background image to show with the login page
class LoginBackgroundWidget extends StatelessWidget {
  const LoginBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Determine colors based on theme
    final bgHex = theme.scaffoldBackgroundColor.toHexIgnoreAlpha();
    final primaryHex = colors.primary.toHexIgnoreAlpha();
    final secondaryHex = colors.secondary.toHexIgnoreAlpha();

    final String svgString = '''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 900">
      <defs>
        <linearGradient id="wave1" x1="0%" y1="100%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="$secondaryHex" stop-opacity="0.1"/>
          <stop offset="100%" stop-color="$primaryHex" stop-opacity="0.3"/>
        </linearGradient>
        
        <linearGradient id="wave2" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="$primaryHex" stop-opacity="0.05"/>
          <stop offset="100%" stop-color="$secondaryHex" stop-opacity="0.2"/>
        </linearGradient>
      </defs>

      <rect width="1440" height="900" fill="$bgHex"/>

      <path fill="url(#wave2)" d="M0,600 C300,450 600,750 1440,300 L1440,900 L0,900 Z"/>
      <path fill="url(#wave1)" d="M0,800 C400,600 800,850 1440,450 L1440,900 L0,900 Z"/>
    </svg>
    ''';

    return SvgPicture.string(
      svgString,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
