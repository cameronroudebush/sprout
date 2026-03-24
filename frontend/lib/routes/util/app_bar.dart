import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/notification/widgets/notification_bell.dart';
import 'package:sprout/shared/widgets/icon.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/logo.dart';

/// The top bar rendered on various pages
class SproutAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SproutAppBar({super.key});

  static const double _defaultHeight = 48.0;

  @override
  Size get preferredSize => const Size.fromHeight(_defaultHeight + 4.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authNotifier = ref.watch(authProvider.notifier);

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final logo = isDesktop || authNotifier.isSetupMode ? SproutLogo(124) : SproutIcon(40);

      return AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: _defaultHeight,
        scrolledUnderElevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme.copyWith(color: theme.colorScheme.onPrimaryContainer),
        elevation: 0,
        centerTitle: true,
        title: logo,
        actions: [if (!isDesktop && !authNotifier.isSetupMode) const NotificationBell(isDesktop: false)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: theme.dividerColor, height: 4.0),
        ),
      );
    });
  }
}
