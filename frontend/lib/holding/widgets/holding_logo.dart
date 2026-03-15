import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/logo_base.dart';

/// A widget used to display a logo for a specific holding. Utilizes a stock icon registry
class HoldingLogo extends LogoBaseWidget<Holding> {
  const HoldingLogo(super.logoClass, {super.key});

  @override
  ({String? faviconImageUrl, String? fullImageUrl}) getLogoUrl(BuildContext context) {
    final url = "https://cdn.nvstly.com/icons/stocks/${logoClass.symbol}.png";
    return (faviconImageUrl: null, fullImageUrl: url);
  }

  @override
  IconData getFallbackIcon(BuildContext context) {
    return Icons.stacked_line_chart_rounded;
  }
}
