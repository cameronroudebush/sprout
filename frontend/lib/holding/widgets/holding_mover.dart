import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/models/expanded_holding.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';

/// A widget that displays the top market gainers and losers from the users holdings.
class HoldingMoverWidget extends ConsumerWidget {
  final String title;
  final List<Account> investmentAccounts;
  final int count;

  const HoldingMoverWidget(
      {super.key, this.title = "Today's Top Movers", required this.investmentAccounts, this.count = 4});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);

    final List<ExpandedHolding> allStates = [];

    for (final account in investmentAccounts) {
      final holdings = ref.watch(accountHoldingsProvider(account.id)).value ?? [];
      for (final holding in holdings) {
        final state = ref.watch(expandedHoldingProvider(holding));
        allStates.add(state);
      }
    }

    allStates.sort((a, b) => b.dayPercent.compareTo(a.dayPercent));

    final gainers = allStates.where((s) => s.dayPercent > 0).take(count).toList();
    final losers = allStates.where((s) => s.dayPercent < 0).toList().reversed.take(count).toList();

    if (gainers.isEmpty && losers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 500;

              if (isCompact) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (gainers.isNotEmpty) _buildMoverList(context, "Top Gainers", gainers, formatter, isGainer: true),
                    if (gainers.isNotEmpty && losers.isNotEmpty) const Divider(height: 32),
                    if (losers.isNotEmpty) _buildMoverList(context, "Top Losers", losers, formatter, isGainer: false),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (gainers.isNotEmpty)
                    Expanded(child: _buildMoverList(context, "Top Gainers", gainers, formatter, isGainer: true)),
                  if (gainers.isNotEmpty && losers.isNotEmpty) const SizedBox(width: 32),
                  if (losers.isNotEmpty)
                    Expanded(child: _buildMoverList(context, "Top Losers", losers, formatter, isGainer: false)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the list of movers
  Widget _buildMoverList(BuildContext context, String title, List<ExpandedHolding> movers, CurrencyFormatter formatter,
      {required bool isGainer}) {
    final theme = Theme.of(context);
    final sectionColor = isGainer ? Colors.green : Colors.redAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(
              isGainer ? Icons.trending_up : Icons.trending_down,
              size: 16,
              color: sectionColor,
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movers.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
          itemBuilder: (context, index) {
            final mover = movers[index];

            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                mover.holding.symbol,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatter.format(mover.liveMarketValue),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SproutChangeWidget(
                    totalChange: mover.dayChange,
                    percentageChange: mover.dayPercent,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
