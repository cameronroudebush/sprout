import 'package:flutter/material.dart';
import 'package:sprout/core/models/finance_provider_config.dart';
import 'package:sprout/core/widgets/logo_base.dart';

/// A widget used to display finance provider logos
class FinanceProviderLogoWidget extends LogoBaseWidget<FinanceProviderConfig> {
  @override
  double get height => 40;

  @override
  double get width => 40;

  const FinanceProviderLogoWidget(super.logoClass, {super.key});

  @override
  String getLogoUrl(BuildContext context) {
    return "${getBackendProxy(context)}?fullImageUrl=${logoClass.logoUrl}";
  }

  @override
  IconData getFallbackIcon(BuildContext context) {
    return Icons.api;
  }
}
