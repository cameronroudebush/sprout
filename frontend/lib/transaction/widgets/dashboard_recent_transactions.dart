import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Renders the recent number of transactions in a card intended for the dashboard
class DashboardRecentTransactionsCard extends ConsumerWidget {
  /// How many recent transactions we want
  final int count;

  const DashboardRecentTransactionsCard({super.key, this.count = 10});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(transactionsProvider);
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "RECENT ACTIVITY",
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                FilledButton(
                  onPressed: () => NavigationProvider.redirect('/transactions'),
                  style: ThemeHelpers.primaryButton,
                  child: const Text("See All"),
                ),
              ],
            ),
            transactionsAsync.when(
              data: (state) {
                final recent = state.transactions.take(count).toList();
                if (recent.isEmpty) {
                  return const Center(child: Text("No recent transactions"));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return TransactionRow(transaction: recent[index], isPrivate: isPrivate);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text("Failed to load transactions")),
            ),
          ],
        ),
      ),
    );
  }
}
