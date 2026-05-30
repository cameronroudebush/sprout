import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
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

  /// If true, and [showDetails] is false, clicking one of these will instead open a popup
  final bool detailsPopup;

  /// Optional title displayed above the calendar
  final String? title;

  /// Target icon sizing
  final double? iconSize;

  const SubscriptionCalendarWidget(
      {super.key, this.showDetails = true, this.detailsPopup = true, this.title, this.iconSize});

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
      error: (err, _) => const SproutCard(
        child: SizedBox(height: 300, child: Center(child: Text("Error loading subscriptions"))),
      ),
      data: (subs) {
        if (subs.isEmpty) return _buildEmptyState(theme);

        final eventsForCurrentDay = subs.where((s) => s.isBilledOn(_selectedDay)).toList();

        return SproutLayoutBuilder((isDesktop, context, constraints) {
          if (isDesktop) {
            // Desktop Layout: Side-by-side alignment splits
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _buildCalendarCard(subs, theme, isDesktop),
                ),
                if (widget.showDetails)
                  Expanded(
                    flex: 5,
                    child: _buildSelectedDayCard(eventsForCurrentDay),
                  ),
              ],
            );
          }

          // Fallback Mobile Layout: Traditional stacked sequence arrangement column pass
          return Column(
            spacing: 6,
            children: [
              _buildCalendarCard(subs, theme, isDesktop),
              if (widget.showDetails) _buildSelectedDayCard(eventsForCurrentDay),
            ],
          );
        });
      },
    );
  }

  /// Builds the calendar card to display in a calendar format of when the subs are
  Widget _buildCalendarCard(List<TransactionSubscription> subs, ThemeData theme, bool isDesktop) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
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

                // Open the popup if details are hidden, popups are active, and there are actual events
                if (!widget.showDetails && widget.detailsPopup && events.isNotEmpty) {
                  final typedEvents = events.cast<TransactionSubscription>().toList();
                  _openDetailsPopup(typedEvents);
                }
              },
              dayDisplay: (context, events) {
                return SproutLayoutBuilder((_, context, constraints) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  final iconSize = widget.iconSize ?? (isDesktop ? 28 : 12);

                  final maxLogos = (constraints.maxWidth / (iconSize + 4)).floor().clamp(0, events.length);
                  final displayedEvents = events.take(maxLogos).toList();
                  final remainingCount = events.length - displayedEvents.length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      ...displayedEvents.map(
                        (e) => AccountIcon(e.account, size: iconSize.toDouble()),
                      ),
                      if (remainingCount > 0) Text("+$remainingCount", style: TextStyle(fontSize: iconSize * 0.8)),
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
  Widget _buildSelectedDayCard(List<TransactionSubscription> events, {bool isInPopup = false}) {
    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(DateFormat.yMMMMd().format(_selectedDay), style: const TextStyle(fontSize: 16)),
        ),
        const Divider(height: 1),
        if (events.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Text("No subscriptions billed today"))
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: isInPopup ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final event = events[i];
                return TransactionRow(events[i].toMockTransaction(),
                    allowDialog: false,
                    icon: AccountIcon(
                      event.account,
                      size: 24,
                    ));
              },
            ),
          ),
      ],
    );

    // If it's loaded in a popup dialog, we don't want a double card shadow layout
    if (isInPopup) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: cardContent,
      );
    }

    return SproutCard(child: cardContent);
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

  /// Used to show a popup of subscription details instead of rendering below the calendar.
  void _openDetailsPopup(List<TransactionSubscription> events) {
    showSproutPopup(
      context: context,
      builder: (ctx) => SproutBaseDialogWidget(
        'Subscription Details',
        showCloseDialogButton: true,
        showSubmitButton: false,
        child: Column(
          spacing: 8,
          children: [
            const Text("Display's the expected subscriptions for the date below"),
            _buildSelectedDayCard(events, isInPopup: true)
          ],
        ),
      ),
    );
  }
}
