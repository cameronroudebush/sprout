import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/logo_provider.dart';
import 'package:sprout/shared/widgets/logo_base.dart';

/// A widget used to display an account icon based on the institution
class AccountIcon extends LogoBaseWidget<Account> {
  /// Creates an [AccountIcon] instance.
  const AccountIcon(
    super.logoClass, {
    super.key,
    super.size,
  });

  @override
  ProviderListenable<AsyncValue<List<String>>> getProvider(BuildContext context, Account data, double size) {
    return institutionIconProvider(data.institution, size);
  }
}
