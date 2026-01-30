import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/notification/widgets/notification_item.dart';

/// The bar at the top of the screen we wish to render
class SproutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenHeight;

  /// If true, we'll use the full logo and center it and only display it
  final bool useFullLogo;

  const SproutAppBar({super.key, required this.screenHeight, this.useFullLogo = false});

  static double getHeightFromScreenHeight(double screenHeight) {
    return 64;
  }

  @override
  Size get preferredSize => Size.fromHeight(getHeightFromScreenHeight(screenHeight));

  // Function called when the notification menu is opened
  Future<void> _markAllAsRead(NotificationProvider provider) async {
    if (provider.hasUnread) await provider.api.notificationControllerMarkAllRead();
    provider.clearAllOverlays();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final size = MediaQuery.of(context).size;

        return SproutLayoutBuilder((isDesktop, context, constraints) {
          final logo = useFullLogo || isDesktop
              ? Image.asset('assets/logo/color-transparent-no-tag.png', width: 128, fit: BoxFit.contain)
              : Image.asset('assets/icon/color.png', width: 48, fit: BoxFit.contain);

          return AppBar(
            automaticallyImplyLeading: kIsWeb && isDesktop ? false : true,
            toolbarHeight: preferredSize.height,
            scrolledUnderElevation: 0,
            backgroundColor: theme.colorScheme.primaryContainer,
            elevation: 0,
            centerTitle: true,
            title: logo,
            actions: [
              // Notification Menu
              if (!useFullLogo)
                PopupMenuButton<String>(
                  onOpened: () => _markAllAsRead(provider),
                  padding: EdgeInsetsGeometry.zero,
                  menuPadding: EdgeInsetsGeometry.zero,
                  offset: const Offset(0, 50),
                  constraints: BoxConstraints(maxHeight: size.height * 0.4, maxWidth: isDesktop ? 520 : 340),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  icon: NotificationItem.buildNotificationIcon(provider.hasUnread),
                  itemBuilder: (context) {
                    return provider.notifications.isEmpty
                        ? [const PopupMenuItem<String>(enabled: false, child: Center(child: Text('No notifications')))]
                        : provider.notifications
                              .map((n) => PopupMenuItem<String>(padding: EdgeInsets.zero, child: NotificationItem(n)))
                              .toList();
                  },
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(8.0),
              child: Container(color: theme.colorScheme.secondary, height: 8.0),
            ),
          );
        });
      },
    );
  }
}
