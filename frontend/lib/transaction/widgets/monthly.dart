import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/widgets/calendar.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/transaction/model/transaction_subscription_extensions.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// This display shows monthly subscriptions in a calendar like format
class TransactionMonthlySubscriptions extends StatefulWidget {
  const TransactionMonthlySubscriptions({super.key});

  @override
  State<TransactionMonthlySubscriptions> createState() => _TransactionMonthlySubscriptionsState();
}

class _TransactionMonthlySubscriptionsState extends State<TransactionMonthlySubscriptions> {
  /// The events for the current day that we have selected
  List<TransactionSubscription> _eventsForCurrentDay = [];

  /// The current selected day in the calendar
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final mediaQuery = MediaQuery.of(context).size;
    final iconSize = mediaQuery.height * .02;

    if (provider.isLoading) return Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Help information
        SproutCard(
          child: Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: Column(
              children: [
                TextWidget(referenceSize: 1.25, text: "Sprout has found these recurring transactions for you."),
              ],
            ),
          ),
        ),
        // Calendar display
        SproutCard(
          child: SproutCalendar(
            provider.subscriptions,
            (day, event) => event.isBilledOn(day),
            onDaySelected: (day, events) {
              setState(() {
                _eventsForCurrentDay = events;
                _selectedDay = day;
              });
            },
            dayDisplay: (context, events) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (iconSize <= 0) return const SizedBox.shrink();

                  const counterWidth = 28.0;
                  final cellWidth = constraints.maxWidth;
                  int maxLogos;

                  final absoluteMaxLogos = (cellWidth / iconSize).floor();

                  if (events.length <= absoluteMaxLogos) {
                    // No counter needed, all logos fit.
                    maxLogos = events.length;
                  } else {
                    // A counter is needed, so reserve space for it first.
                    final availableWidthForLogos = cellWidth - counterWidth;
                    maxLogos = (availableWidthForLogos / iconSize).floor();
                    // Ensure maxLogos isn't negative if the cell is tiny.
                    if (maxLogos < 0) maxLogos = 0;
                  }

                  final displayedEvents = events.take(maxLogos).toList();
                  final remainingEventsCount = events.length - displayedEvents.length;

                  return Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: displayedEvents
                            .map((e) => AccountLogoWidget(e.account, height: iconSize, width: iconSize))
                            .toList(),
                      ),
                      if (remainingEventsCount > 0)
                        TextWidget(text: "+$remainingEventsCount", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
                },
              );
            },
          ),
        ),
        // Selected day information
        SproutCard(
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 12),
            child: Column(
              spacing: 0,
              children: [
                TextWidget(text: DateFormat.yMMMMd().format(_selectedDay), referenceSize: 1.5),
                const SizedBox(height: 12),
                const Divider(height: 1),
                // No available subscriptions
                if (_eventsForCurrentDay.isEmpty)
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 24),
                    child: TextWidget(text: "No available subscriptions for this day", referenceSize: 1.25),
                  ),
                if (_eventsForCurrentDay.isNotEmpty)
                  ..._eventsForCurrentDay.mapIndexed((i, e) {
                    // Mock this as a transaction
                    final transaction = e.toMockTransaction();
                    return TransactionRow(
                      transaction: transaction,
                      isEvenRow: i % 2 == 0,
                      renderPostedTime: false,
                      allowDialog: false,
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
