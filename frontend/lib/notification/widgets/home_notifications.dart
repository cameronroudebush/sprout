import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';

/// A widget that displays important notifications to the user immediately
class HomeNotificationsWidget extends ConsumerWidget {
  const HomeNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final config = ref.watch(secureConfigProvider).value;
    final unknownCatCount = ref.watch(unknownCategoryCountProvider()).value ?? 0;

    final List<Widget> notifications = [];

    // Sync Status Notification
    final lastSync = config?.lastSchedulerRun;
    if (lastSync != null &&
        (lastSync.status == ModelSyncStatusEnum.inProgress || lastSync.status == ModelSyncStatusEnum.failed)) {
      String message = "An account sync has not yet run today";
      Color bgColor = theme.colorScheme.error;
      Color textColor = theme.colorScheme.onError;

      if (lastSync.status == ModelSyncStatusEnum.inProgress) {
        bgColor = theme.colorScheme.secondary;
        textColor = theme.colorScheme.onSecondary;
        message = "An account sync is in progress";
      } else if (lastSync.status == ModelSyncStatusEnum.failed) {
        message = "Account sync error: ${lastSync.failureReason}";
      }

      notifications.add(SproutNotificationWidget(SproutNotification(message, bgColor, textColor, icon: Icons.sync)));
    }

    // Uncategorized Transactions Notification
    if (unknownCatCount > 0) {
      notifications.add(
        SproutNotificationWidget(
          SproutNotification(
            "You have $unknownCatCount uncategorized transactions",
            theme.colorScheme.primary,
            theme.colorScheme.onPrimary,
            icon: Icons.category,
            onClick: () => NavigationProvider.redirect("/transactions", queryParameters: {'cat': "unknown"}),
          ),
        ),
      );
    }

    if (notifications.isEmpty) return const SizedBox.shrink();
    return Column(spacing: 0, children: notifications);
  }
}
