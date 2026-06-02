import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_total_summary_card.dart';
import 'package:sprout/account/widgets/accounts_summary.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';

/// A widget that provides a high-level overview of all accounts for the dashboard.
class DashboardAccountsCard extends ConsumerWidget {
  const DashboardAccountsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return SproutCard(
        child: accountsAsync.whenDefault(
      data: (state) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (state.accounts.isNotEmpty) TotalSummary(accounts: state.accounts),
            Flexible(
              child: SingleChildScrollView(
                child: AccountSummaryView(
                  accounts: state.accounts,
                  individualCards: false,
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
