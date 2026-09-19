import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';

/// A widget that displays a notification for accounts/institutions experiencing connection errors.
class AccountErrorNotificationWidget extends ConsumerWidget {
  final bool allowClick;
  const AccountErrorNotificationWidget({
    super.key,
    this.allowClick = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsData = ref.watch(accountsProvider).value;
    final accounts = accountsData?.accounts ?? [];

    final brokenAccounts = accounts.where((account) => account.hasProblem).toList();

    if (brokenAccounts.isEmpty) return const SizedBox.shrink();

    String message;

    if (brokenAccounts.length == 1) {
      final account = brokenAccounts.first;
      if (account.isArchived) {
        message = "Account '${account.name}' is archived and needs review";
      } else {
        message = "Connection lost with ${account.institution.name}";
      }
    } else {
      final archivedCount = brokenAccounts.where((a) => a.isArchived).length;
      final connectionErrorCount = brokenAccounts.length - archivedCount;

      if (archivedCount > 0 && connectionErrorCount > 0) {
        final connText = connectionErrorCount == 1 ? "1 connection error" : "$connectionErrorCount connection errors";
        final archText = archivedCount == 1 ? "1 archived account" : "$archivedCount archived accounts";
        message = "$connText and $archText require attention";
      } else if (archivedCount > 0) {
        message = archivedCount == 1
            ? "1 archived account requires review"
            : "$archivedCount archived accounts require review";
      } else {
        message = connectionErrorCount == 1
            ? "Connection error found across 1 financial institution"
            : "Connection errors found across $connectionErrorCount financial institutions";
      }
    }

    return SproutNotificationWidget(
      SproutNotification(
        message,
        theme.colorScheme.errorContainer,
        theme.colorScheme.onErrorContainer,
        icon: Icons.error_outline,
        onClick: allowClick ? () => NavigationProvider.redirect("/accounts") : null,
      ),
    );
  }
}
