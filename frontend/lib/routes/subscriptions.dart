import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/models/extensions/transaction_subscription_extensions.dart';
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
    final focusedMonth = ref.watch(selectedCalendarMonthProvider);

    final totalHeader = subsAsync.maybeWhen(
      data: (subs) => subs.isEmpty ? const SizedBox.shrink() : _buildTotal(subs, focusedMonth, theme, formatter),
      orElse: () => const SizedBox.shrink(),
    );

    return SproutRouteWrapper(
      size: SproutRouteSize.large,
      child: SproutLayoutBuilder(
        (isDesktop, context, constraints) {
          // Mobile
          if (!isDesktop) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    totalHeader,
                    const SubscriptionCalendarWidget(),
                  ],
                ),
              ),
            );
          }

          // Desktop
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              totalHeader,
              const Expanded(child: SubscriptionCalendarWidget()),
            ],
          );
        },
      ),
    );
  }

  /// Builds the total widget that shows how much our monthly cost of subscriptions are and how many of them we have
  Widget _buildTotal(
      List<TransactionSubscription> subs, DateTime focusedMonth, ThemeData theme, CurrencyFormatter formatter) {
    double dynamicTotal = 0;
    int itemsBillingThisMonthCount = 0;

    // Determine target month boundary frames
    final daysInMonth = DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);

    for (final sub in subs) {
      int billingOccurrencesInMonth = 0;

      // Loop through every day of the actively focused view container month
      for (int day = 1; day <= daysInMonth; day++) {
        final checkDay = DateTime(focusedMonth.year, focusedMonth.month, day);
        if (sub.isBilledOn(checkDay)) billingOccurrencesInMonth++;
      }

      if (billingOccurrencesInMonth > 0) {
        dynamicTotal += (sub.amount * billingOccurrencesInMonth);
        itemsBillingThisMonthCount++;
      }
    }

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("Active Month Expenses", itemsBillingThisMonthCount.toString(), null),
            _buildStatColumn("Estimated Cost This Month", formatter.format(dynamicTotal), theme.colorScheme.error),
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
