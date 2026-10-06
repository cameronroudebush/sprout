import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/logo_provider.dart';
import 'package:sprout/shared/widgets/logo_base.dart';

/// A widget used to display a full institution logo
class AccountLogo extends LogoBaseWidget<Account> {
  /// Creates an [AccountLogo] instance.
  const AccountLogo(
    super.logoClass, {
    super.key,
    super.size,
  });

  @override
  ProviderListenable<AsyncValue<List<String>>> getProvider(
      BuildContext context, Account data, double size) {
    return institutionLogoProvider(data.institution, size);
  }
}
