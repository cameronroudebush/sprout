import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/subscriptions_calendar.dart';

/// This page provides a view for seeing what subscriptions Sprout has identified based on the re-occurring transactions
class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final subsAsync = ref.watch(transactionSubscriptionsProvider);

    return SproutRouteWrapper(
      size: SproutRouteSize.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          subsAsync.maybeWhen(
            data: (subs) => subs.isEmpty ? const SizedBox.shrink() : _buildTotal(subs, theme, formatter),
            orElse: () => const SizedBox.shrink(),
          ),
          const Expanded(child: SubscriptionCalendarWidget()),
        ],
      ),
    );
  }

  /// Builds the total widget that shows how much our monthly cost of subscriptions are and how many of them we have
  Widget _buildTotal(List<TransactionSubscription> subs, ThemeData theme, CurrencyFormatter formatter) {
    final total = subs.isEmpty ? 0 : subs.map((e) => e.amount).reduce((a, b) => a + b);

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("Total Subscriptions", subs.length.toString(), null),
            _buildStatColumn("Total Monthly Cost", formatter.format(total), theme.colorScheme.error),
          ],
        ),
      ),
    );
  }

  /// Builds the stat column for the total
  Widget _buildStatColumn(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(value, style: TextStyle(fontSize: 16, color: valueColor)),
      ],
    );
  }
}
