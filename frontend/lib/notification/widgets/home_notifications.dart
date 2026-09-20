import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/account_error_top_notification.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';

/// A widget that displays important notifications to the user immediately
class HomeNotificationsWidget extends ConsumerWidget {
  const HomeNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final unknownCatCount = ref.watch(unknownCategoryCountProvider()).value ?? 0;

    final List<Widget> notifications = [];

    // Account Error Notification
    notifications.add(const AccountErrorNotificationWidget());

    // Uncategorized Transactions Notification
    if (unknownCatCount > 0) {
      notifications.add(
        SproutNotificationWidget(
          SproutNotification(
            "You have $unknownCatCount uncategorized transactions",
            theme.colorScheme.primary,
            theme.colorScheme.onPrimary,
            icon: Icons.category,
            onClick: () => NavigationProvider.redirect("/transactions", queryParameters: {
              'categoryId': "unknown",
              'pending': "false",
            }),
          ),
        ),
      );
    }

    // Filter out empty shrink widgets if no notifications are active
    final activeNotifications = notifications.where((w) => w is! SizedBox).toList();

    if (activeNotifications.isEmpty) return const SizedBox.shrink();
    return Column(spacing: 0, children: activeNotifications);
  }
}
