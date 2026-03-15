import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/notification/widgets/notification_item.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// The top bar rendered on various pages
class SproutAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// If true, we'll use the full logo and center it and only display it
  final bool useFullLogo;

  const SproutAppBar({super.key, this.useFullLogo = false});

  static const double _defaultHeight = 48.0;

  @override
  Size get preferredSize => const Size.fromHeight(_defaultHeight + 4.0);

  Future<void> _handleNotificationMenuOpened(WidgetRef ref) async {
    final notifier = ref.read(notificationsProvider.notifier);

    if (notifier.hasUnread) {
      final api = await ref.read(notificationApiProvider.future);
      await api.notificationControllerMarkAllRead();
      ref.invalidate(notificationsProvider);
    }

    notifier.clearAllOverlays();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    final notificationState = ref.watch(notificationsProvider);
    final notificationNotifier = ref.watch(notificationsProvider.notifier);

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final logo = useFullLogo || isDesktop
          ? Image.asset('assets/logo/color-transparent-no-tag.png', width: 128, fit: BoxFit.contain)
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
          if (!useFullLogo)
            PopupMenuButton<String>(
              onOpened: () => _handleNotificationMenuOpened(ref),
              padding: EdgeInsets.zero,
              menuPadding: EdgeInsets.zero,
              offset: const Offset(0, 50),
              constraints: BoxConstraints(maxHeight: size.height * 0.4, maxWidth: isDesktop ? 520 : 340),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
              icon: NotificationItem.buildNotificationIcon(notificationNotifier.hasUnread),
              itemBuilder: (context) {
                return notificationState.when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return [
                        const PopupMenuItem<String>(enabled: false, child: Center(child: Text('No notifications'))),
                      ];
                    }
                    return notifications
                        .map((n) => PopupMenuItem<String>(padding: EdgeInsets.zero, child: NotificationItem(n)))
                        .toList();
                  },
                  loading: () => [
                    const PopupMenuItem(enabled: false, child: Center(child: CircularProgressIndicator())),
                  ],
                  error: (err, _) => [
                    const PopupMenuItem(enabled: false, child: Center(child: Text('Error loading notifications'))),
                  ],
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: theme.dividerColor, height: 4.0),
        ),
      );
    });
  }
}
