import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/logo_base.dart';
import 'package:sprout/holding/models/holding.dart';

/// A widget used to display an account logo
class HoldingLogoWidget extends LogoBaseWidget<Holding> {
  const HoldingLogoWidget(super.logoClass, {super.key});

  @override
  String getLogoUrl(BuildContext context) {
    final url = "https://cdn.nvstly.com/icons/stocks/${logoClass.symbol}.png";
    return "${getBackendProxy(context)}?fullImageUrl=$url";
  }

  @override
  IconData getFallbackIcon(BuildContext context) {
    return Icons.stacked_line_chart_rounded;
  }
}
