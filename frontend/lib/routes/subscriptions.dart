import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/calendar.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/models/extensions/transaction_subscription_extensions.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';
import 'package:sprout/user/user_config_provider.dart';

/// This page provides a view for seeing what subscriptions Sprout has identified based on the re-occurring transactions
class SubscriptionsPage extends ConsumerStatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  ConsumerState<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends ConsumerState<SubscriptionsPage> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subsAsync = ref.watch(transactionSubscriptionsProvider);

    return subsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (subs) {
        if (subs.isEmpty) return _buildEmptyState(theme);

        // Calculate events for the currently selected day
        final eventsForCurrentDay = subs.where((s) => s.isBilledOn(_selectedDay)).toList();

        return SproutLayoutBuilder((isDesktop, context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              spacing: 4,
              children: [
                _buildTotal(subs, theme),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Expanded(flex: 2, child: _buildCalendarCard(subs)),
                      Expanded(flex: 3, child: _buildSelectedDayCard(eventsForCurrentDay)),
                    ],
                  )
                else ...[
                  _buildCalendarCard(subs),
                  _buildSelectedDayCard(eventsForCurrentDay),
                ],
              ],
            ),
          );
        });
      },
    );
  }

  /// Builds the total widget that shows how much our monthly cost of subscriptions are and how many of them we have
  Widget _buildTotal(List<TransactionSubscription> subs, ThemeData theme) {
    final total = subs.isEmpty ? 0 : subs.map((e) => e.amount).reduce((a, b) => a + b);
    final privateMode = ref.watch(userConfigProvider).value?.privateMode ?? false;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("Total Subscriptions", subs.length.toString(), null),
            _buildStatColumn("Total Monthly Cost", total.toCurrency(privateMode), theme.colorScheme.error),
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

  /// Builds the calendar card to display in a calendar format of when the subs are
  Widget _buildCalendarCard(List<TransactionSubscription> subs) {
    return SproutCard(
      child: SproutCalendar(
        subs,
        (day, event) => event.isBilledOn(day),
        onDaySelected: (day, events) {
          setState(() => _selectedDay = day);
        },
        dayDisplay: (context, events) {
          return SproutLayoutBuilder((isDesktop, context, constraints) {
            final double effectiveIconSize = isDesktop ? 18.0 : 14.0;
            if (events.isEmpty) return const SizedBox.shrink();

            final maxLogos = (constraints.maxWidth / (effectiveIconSize + 4)).floor().clamp(0, events.length);
            final displayedEvents = events.take(maxLogos).toList();
            final remainingCount = events.length - displayedEvents.length;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                ...displayedEvents.map(
                  (e) => AccountLogo(e.account, height: effectiveIconSize, width: effectiveIconSize),
                ),
                if (remainingCount > 0) Text("+$remainingCount", style: TextStyle(fontSize: effectiveIconSize * 0.8)),
              ],
            );
          });
        },
      ),
    );
  }

  /// Builds the card that shows what transaction subscriptions are available for the current day. This utilizes
  ///   a standard transaction row for simplifying capability.
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
                Text("No Subscriptions Found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text(
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
