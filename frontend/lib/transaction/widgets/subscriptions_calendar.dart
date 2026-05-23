import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/calendar.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/models/extensions/transaction_subscription_extensions.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// A reusable calendar widget that displays detected recurring subscriptions.
class SubscriptionCalendarWidget extends ConsumerStatefulWidget {
  /// Whether to show the detailed transaction list for the selected day below the calendar.
  final bool showDetails;

  /// Optional title displayed above the calendar
  final String? title;

  const SubscriptionCalendarWidget({super.key, this.showDetails = true, this.title});

  @override
  ConsumerState<SubscriptionCalendarWidget> createState() => _SubscriptionCalendarWidgetState();
}

class _SubscriptionCalendarWidgetState extends ConsumerState<SubscriptionCalendarWidget> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subsAsync = ref.watch(transactionSubscriptionsProvider);

    return subsAsync.when(
      loading: () => const SproutCard(
        child: SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
      ),
      error: (err, _) => SproutCard(
        child: SizedBox(height: 300, child: Center(child: Text("Error loading subscriptions"))),
      ),
      data: (subs) {
        if (subs.isEmpty) return _buildEmptyState(theme);

        final eventsForCurrentDay = subs.where((s) => s.isBilledOn(_selectedDay)).toList();

        return Column(
          spacing: 12,
          children: [
            _buildCalendarCard(subs, theme),
            if (widget.showDetails) _buildSelectedDayCard(eventsForCurrentDay),
          ],
        );
      },
    );
  }

  /// Builds the calendar card to display in a calendar format of when the subs are
  Widget _buildCalendarCard(List<TransactionSubscription> subs, ThemeData theme) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          children: [
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Text(
                  widget.title!,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            SproutCalendar(
              subs,
              (day, event) => event.isBilledOn(day),
              onDaySelected: (day, events) {
                setState(() => _selectedDay = day);
              },
              dayDisplay: (context, events) {
                return SproutLayoutBuilder((isDesktop, context, constraints) {
                  final double effectiveIconSize = 24;
                  if (events.isEmpty) return const SizedBox.shrink();

                  final maxLogos = (constraints.maxWidth / (effectiveIconSize + 4)).floor().clamp(0, events.length);
                  final displayedEvents = events.take(maxLogos).toList();
                  final remainingCount = events.length - displayedEvents.length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      ...displayedEvents.map(
                        (e) => AccountIcon(e.account, size: effectiveIconSize),
                      ),
                      if (remainingCount > 0)
                        Text("+$remainingCount", style: TextStyle(fontSize: effectiveIconSize * 0.8)),
                    ],
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the card that shows what transaction subscriptions are available for the current day.
  Widget _buildSelectedDayCard(List<TransactionSubscription> events) {
    return SproutCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(DateFormat.yMMMMd().format(_selectedDay), style: const TextStyle(fontSize: 16)),
          ),
          const Divider(height: 1),
          if (events.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Text("No subscriptions billed today"))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => TransactionRow(events[i].toMockTransaction(), allowDialog: false),
            ),
        ],
      ),
    );
  }

  /// Builds a display of what to do when we have no subscriptions
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SizedBox(
        height: 220,
        child: SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              spacing: 12,
              children: [
                Icon(Icons.calendar_month, size: 48, color: theme.colorScheme.primary),
                const Text("No Subscriptions Found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Text(
                  "Sprout detects recurring bills automatically from your history. Check back later to see if Sprout has detected any.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
