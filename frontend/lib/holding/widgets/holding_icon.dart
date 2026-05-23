import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/logo_provider.dart';
import 'package:sprout/shared/widgets/logo_base.dart';

/// A widget used to display a logo for a specific holding
class HoldingIcon extends LogoBaseWidget<Holding> {
  @override
  double get size => 36;

  /// The account that has this holding
  final Account account;

  const HoldingIcon(super.logoClass, this.account, {super.key});

  @override
  ProviderListenable<AsyncValue<List<String>>> getProvider(BuildContext context, Holding data, double size) {
    return tickerIconProvider(logoClass, account.institution, size);
  }

  @override
  Icon getFallbackIcon(BuildContext context) {
    return Icon(Icons.trending_up, size: size);
  }
}
