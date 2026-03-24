import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/notification/widgets/notification_bell.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// The top bar rendered on various pages
class SproutAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// If true, we'll use the full logo and center it and only display it
  final bool useFullLogo;

  const SproutAppBar({super.key, this.useFullLogo = false});

  static const double _defaultHeight = 48.0;

  @override
  Size get preferredSize => const Size.fromHeight(_defaultHeight + 4.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authNotifier = ref.watch(authProvider.notifier);

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final logo = useFullLogo || isDesktop || authNotifier.isSetupMode
          ? Image.asset('assets/logo/color-transparent-no-tag.png', width: 116, fit: BoxFit.contain)
          : Image.asset('assets/icon/color.png', width: 48, fit: BoxFit.contain);

      return AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: _defaultHeight,
        scrolledUnderElevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme.copyWith(color: theme.colorScheme.onPrimaryContainer),
        elevation: 0,
        centerTitle: true,
        title: logo,
        actions: [
          if (!useFullLogo && !authNotifier.isSetupMode)
            NotificationBell(
              isDesktop: false,
            )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: theme.dividerColor, height: 4.0),
        ),
      );
    });
  }
}
