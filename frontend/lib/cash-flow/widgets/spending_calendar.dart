import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/shared/widgets/calendar.dart';
import 'package:sprout/shared/widgets/card.dart';

/// A widget that is used to display spending for the current month
class SpendingCalendarWidget extends ConsumerWidget {
  final String? title;

  const SpendingCalendarWidget({super.key, this.title = "Spending Per Day"});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final dailySpendingAsync = ref.watch(dailySpendingProvider(month: now.month, year: now.year));

    return dailySpendingAsync.when(
      loading: () => const SproutCard(
        child: SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
      ),
      error: (err, _) =>
          const SproutCard(child: SizedBox(height: 300, child: Center(child: Text("Error loading spending insights")))),
      data: (spendingMap) {
        final totalDays = DateTime(now.year, now.month + 1, 0).day;
        final listDaysInMonth = List.generate(totalDays, (i) => i + 1);

        return SproutCard(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Column(
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 6),
                    child: Text(
                      title!,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                SproutCalendar(
                  listDaysInMonth,
                  (DateTime gridDay, int dayItem) {
                    return gridDay.month == now.month && gridDay.day == dayItem;
                  },
                  allowSelection: false,
                  dayDisplay: (context, matchingItems) {
                    if (matchingItems.isEmpty) return const SizedBox.shrink();
                    final targetDay = matchingItems.first;
                    final totalSpentToday = spendingMap[targetDay] ?? 0.0;
                    if (totalSpentToday <= 0) return const SizedBox.shrink();
                    final formattedAmount = NumberFormat.compactSimpleCurrency(locale: 'en_US').format(totalSpentToday);
                    return Text(
                      formattedAmount,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
