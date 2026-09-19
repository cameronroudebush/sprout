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

    if (brokenAccounts.length < 2) {
      final account = brokenAccounts.first;
      final name = account.isArchived ? account.name : account.institution.name;
      message = "$name needs fixed";
    } else {
      message = "${brokenAccounts.length} accounts need fixed";
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
