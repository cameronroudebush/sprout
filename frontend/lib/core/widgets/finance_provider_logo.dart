import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/widgets/logo_base.dart';

/// A widget used to display finance provider logos
class FinanceProviderLogoWidget extends LogoBaseWidget<ProviderConfig> {
  @override
  double get height => 30;

  @override
  double get width => 30;

  const FinanceProviderLogoWidget(super.logoClass, {super.key});

  @override
  String getLogoUrl(BuildContext context) {
    return "${getBackendProxy()}?fullImageUrl=${logoClass.logoUrl}";
  }

  @override
  IconData getFallbackIcon(BuildContext context) {
    return Icons.api;
  }
}
