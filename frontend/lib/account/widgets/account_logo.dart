import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/widgets/logo_base.dart';

/// A widget used to display an account logo
class AccountLogoWidget extends LogoBaseWidget<Account> {
  const AccountLogoWidget(super.logoClass, {super.key, super.height, super.width});

  @override
  ({String? faviconImageUrl, String? fullImageUrl}) getLogoUrl(BuildContext context) {
    return (faviconImageUrl: logoClass.institution.id, fullImageUrl: null);
  }

  @override
  IconData getFallbackIcon(BuildContext context) {
    return Icons.account_balance;
  }
}
