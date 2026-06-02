import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/logo_provider.dart';
import 'package:sprout/shared/widgets/logo_base.dart';

/// A widget used to display finance provider logos
class FinanceProviderIcon extends LogoBaseWidget<ProviderConfig> {
  const FinanceProviderIcon(super.logoClass, {super.key, super.size = 64});

  @override
  ProviderListenable<AsyncValue<List<String>>> getProvider(BuildContext context, ProviderConfig data, double size) {
    return providerIconProvider(logoClass, size);
  }

  @override
  Icon getFallbackIcon(BuildContext context) {
    return Icon(Icons.source, size: size);
  }
}
