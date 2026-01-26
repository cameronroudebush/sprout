import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/widgets/logo_base.dart';

/// A widget used to display an account logo
class HoldingLogoWidget extends LogoBaseWidget<Holding> {
  const HoldingLogoWidget(super.logoClass, {super.key});

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
