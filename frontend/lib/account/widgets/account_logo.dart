import 'package:flutter/material.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/widgets/logo_base.dart';

/// A widget used to display an account logo
class AccountLogoWidget extends LogoBaseWidget<Account> {
  const AccountLogoWidget(super.logoClass, {super.key, super.height, super.width});

  @override
  String getLogoUrl(BuildContext context) {
    return "${getBackendProxy(context)}?faviconImageUrl=${logoClass.institution.id}";
  }

  @override
  IconData getFallbackIcon(BuildContext context) {
    return logoClass.fallbackIcon;
  }
}
