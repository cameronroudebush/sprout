import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/calendar.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// A widget that is used to show cash flow in a calendar like format
class CashFlowCalendarWidget extends ConsumerWidget {
  const CashFlowCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dailySpendingAsync = ref.watch(dailySpendingProvider(month: now.month, year: now.year));
    final formatter = ref.watch(currencyFormatterProvider);

    return dailySpendingAsync.whenDefault(
      customErrorMessage: "Error loading spending insights",
      data: (spendingMap) {
        final totalDays = DateTime(now.year, now.month + 1, 0).day;
        final listDaysInMonth = List.generate(totalDays, (i) => i + 1);

        double maxExpense = 0.0;
        double maxIncome = 0.0;

        for (final value in spendingMap.values) {
          if (value < 0) {
            maxExpense = math.max(maxExpense, value.abs());
          } else if (value > 0) {
            maxIncome = math.max(maxIncome, value);
          }
        }

        return SproutCalendar(
          listDaysInMonth,
          (DateTime gridDay, int dayItem) {
            final dateMatches = gridDay.month == now.month && gridDay.day == dayItem;
            final netFlow = spendingMap[dayItem] ?? 0.0;
            final hasFinancialActivity = netFlow != 0.0;

            return dateMatches && hasFinancialActivity;
          },
          subheader: "Cash Flow",
          allowSelection: false,
          onDaySelected: (day, events, wasAutomatic) {
            if (events.isEmpty || wasAutomatic) return;
            showSproutPopup(
              context: context,
              builder: (ctx) => SproutBaseDialogWidget(
                'Spending for ${DateFormat.yMMMd().format(day)}',
                showCloseDialogButton: true,
                showSubmitButton: false,
                child: Consumer(
                  builder: (context, ref, child) {
                    final dayTransactionsAsync = ref.watch(transactionsForDayProvider(day));

                    return dayTransactionsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text("Error loading transactions: $err")),
                      ),
                      data: (dayTransactions) {
                        if (dayTransactions.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text("No transactions recorded for this day"),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: dayTransactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            return TransactionRow(
                              dayTransactions[i],
                              allowDialog: false,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
          cellDecorationBuilder: (context, matchingItems) {
            if (matchingItems.isEmpty) return null;
            final dayItem = matchingItems.first;
            final netFlowToday = spendingMap[dayItem] ?? 0.0;
            if (netFlowToday == 0) return null;
            final isExpense = netFlowToday < 0;
            final absoluteFlow = netFlowToday.abs();
            final maxReference = isExpense ? maxExpense : maxIncome;
            if (maxReference <= 0) return null;
            final intensityRatio = absoluteFlow / maxReference;
            final calculatedAlpha = (intensityRatio * 0.45).clamp(0.05, 0.5);
            final baseColor = isExpense ? theme.colorScheme.error : Colors.green;
            return BoxDecoration(
              color: baseColor.withOpacity(calculatedAlpha),
              borderRadius: BorderRadius.circular(8),
            );
          },
          dayDisplay: (context, matchingItems) {
            if (matchingItems.isEmpty) return const SizedBox.shrink();
            final targetDay = matchingItems.first;
            final netFlowToday = spendingMap[targetDay] ?? 0.0;
            if (netFlowToday == 0) return const SizedBox.shrink();
            final isExpense = netFlowToday < 0;
            final formattedAmount = formatter.format(netFlowToday, compact: true);
            final displayTextColor = isExpense ? theme.colorScheme.error : Colors.green[700];
            return Text(
              formattedAmount,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: displayTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        );
      },
    );
  }
}
