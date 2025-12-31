import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/calendar.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/page_loading.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/transaction/model/transaction_subscription_extensions.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// This display shows monthly subscriptions in a calendar like format
class TransactionMonthlySubscriptions extends StatefulWidget {
  const TransactionMonthlySubscriptions({super.key});

  @override
  State<TransactionMonthlySubscriptions> createState() => _TransactionMonthlySubscriptionsState();
}

class _TransactionMonthlySubscriptionsState extends StateTracker<TransactionMonthlySubscriptions> {
  @override
  Map<dynamic, DataRequest> get requests => {
    'subs': DataRequest<TransactionProvider, dynamic>(
      provider: ServiceLocator.get<TransactionProvider>(),
      onLoad: (p, force) => p.populateSubscriptions(),
      getFromProvider: (p) => p.subscriptions,
    ),
  };

  /// The events for the current day that we have selected
  List<TransactionSubscription> _eventsForCurrentDay = [];

  /// The current selected day in the calendar
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final isLoading = this.isLoading;

        if (isLoading) return PageLoadingWidget(loadingText: "Loading Subscriptions...");

        if (provider.subscriptions.isEmpty) {
          return SizedBox(
            width: 640,
            child: SproutCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 12,
                  children: [
                    Text("No Subscriptions Found", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    const Text(
                      "Sprout automatically identifies subscriptions by analyzing your transactions over the last year. "
                      "For a transaction to be considered a subscription, it must meet the following criteria:",
                      textAlign: TextAlign.center,
                    ),
                    _buildSubscriptionCriteria(),
                  ],
                ),
              ),
            ),
          );
        }

        return SproutLayoutBuilder((isDesktop, context, constraints) {
          final totalCard = _buildTotal(provider);
          final calendarCard = _buildCalendarCard(provider);
          final selectedDayCard = _buildSelectedDayCard();

          if (isDesktop) {
            return Column(
              children: [
                totalCard,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: calendarCard),
                    Expanded(flex: 3, child: selectedDayCard),
                  ],
                ),
              ],
            );
          }

          // Mobile layout
          return Column(children: [totalCard, calendarCard, const SizedBox(height: 8), selectedDayCard]);
        });
      },
    );
  }

  Widget _buildSubscriptionCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCriterion("• Be a negative amount (an expense)."),
        _buildCriterion("• Occur at least a configured number of times in the last year."),
        _buildCriterion("• Have consistent amounts (within a small deviation)."),
        _buildCriterion("• Have consistent billing periods (e.g., monthly, weekly)."),
      ],
    );
  }

  static Widget _buildCriterion(String text) {
    return Padding(padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), child: Text(text));
  }

  Widget _buildTotal(TransactionProvider provider) {
    num total = provider.subscriptions.map((e) => e.amount).reduce((a, b) => a + b);
    return SproutCard(child: Row(children: [Text(getFormattedCurrency(total))]));
  }

  Widget _buildCalendarCard(TransactionProvider provider) {
    return SproutCard(
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
          return SproutLayoutBuilder((isDesktop, context, constraints) {
            final mediaQuery = MediaQuery.of(context).size;
            final double dynamicIconSize = mediaQuery.height * .02;
            final double effectiveIconSize = isDesktop ? 18.0 : dynamicIconSize;

            if (effectiveIconSize <= 0) return const SizedBox.shrink();

            const counterWidth = 28.0;
            final cellWidth = constraints.maxWidth;
            int maxLogos;

            final absoluteMaxLogos = (cellWidth / effectiveIconSize).floor();

            if (events.length <= absoluteMaxLogos) {
              maxLogos = events.length;
            } else {
              final availableWidthForLogos = cellWidth - counterWidth;
              maxLogos = (availableWidthForLogos / effectiveIconSize).floor();
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
                      .map((e) => AccountLogoWidget(e.account, height: effectiveIconSize, width: effectiveIconSize))
                      .toList(),
                ),
                if (remainingEventsCount > 0)
                  Text(
                    "+$remainingEventsCount",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: effectiveIconSize * 0.8),
                  ),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildSelectedDayCard() {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Text(DateFormat.yMMMMd().format(_selectedDay), style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            if (_eventsForCurrentDay.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text("No available subscriptions for this day", style: TextStyle(fontSize: 14)),
              ),
            if (_eventsForCurrentDay.isNotEmpty)
              ..._eventsForCurrentDay.mapIndexed((i, e) {
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
    );
  }
}
