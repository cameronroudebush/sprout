import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// Renders the recent number of transactions in a card intended for the dashboard
class DashboardRecentTransactionsCard extends ConsumerWidget {
  /// How many recent transactions we want
  final int count;

  const DashboardRecentTransactionsCard({super.key, this.count = 10});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(transactionsProvider);

    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(12, 8, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Activity",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: FilledButton(
                    onPressed: () => NavigationProvider.redirect('/transactions'),
                    style: ThemeHelpers.primaryButton,
                    child: const Text("See All"),
                  ),
                ),
              ],
            ),
          ),
          transactionsAsync.when(
            data: (state) {
              final recent = state.transactions.take(count).toList();
              if (recent.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 12),
                    child: Text("No recent transactions"),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  return TransactionRow(recent[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: Text("Failed to load transactions")),
          ),
        ],
      ),
    );
  }
}
