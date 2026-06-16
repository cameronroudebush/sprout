import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/holding_icon.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';

/// This widget shows a specific holding row from an account
class HoldingRow extends ConsumerWidget {
  final Holding holding;
  final bool isSelected;
  final VoidCallback onSelect;

  const HoldingRow({
    super.key,
    required this.holding,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    final rowState = ref.watch(expandedHoldingProvider(holding));

    return InkWell(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
        ),
        child: Row(
          spacing: 12,
          children: [
            if (rowState.account != null) HoldingIcon(holding, rowState.account!),
            // Market data column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  // Symbol & Total Market Value Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(holding.symbol, style: theme.textTheme.titleMedium),
                      Text(
                        formatter.format(rowState.liveMarketValue),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),

                  // Intraday Realtime Live Data Changes
                  if (rowState.isLive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 4,
                          children: [
                            Text(
                              "Intraday Change",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Tooltip(
                              message:
                                  "Calculated using real-time market prices. This reflects the estimated change in your holding's value since the last market value.",
                              child: Icon(
                                Icons.info_outline,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        SproutChangeWidget(
                          totalChange: rowState.dayChange,
                          percentageChange: rowState.dayPercent,
                          fontSize: theme.textTheme.labelMedium!.fontSize!,
                        ),
                      ],
                    ),

                  // Historical Settled Brokerage Delta Values
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Text(
                            "Settled Value Change",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          Tooltip(
                            message:
                                "This is the most recent change reported by ${rowState.account?.provider ?? "Unknown"}. This value updates less often and may lag behind live market movements.",
                            child: Icon(
                              Icons.info_outline,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      if (rowState.historicalFrame != null)
                        SproutChangeWidget(
                          totalChange: rowState.historicalFrame?.valueChange,
                          percentageChange: rowState.historicalFrame?.percentChange,
                          fontSize: theme.textTheme.labelMedium!.fontSize!,
                          useExtendedPeriodString: false,
                        ),
                    ],
                  ),

                  // Total Value Change (All-Time)
                  if (rowState.totalGainPercent != 0)
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(
                        spacing: 4,
                        children: [
                          Text(
                            "Total Value Change",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          Tooltip(
                            message:
                                "The total all-time gains or losses for this holding based on your average cost basis. This value updates less often and may lag behind live market movements.",
                            child: Icon(
                              Icons.info_outline,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      SproutChangeWidget(
                        totalChange: rowState.totalGain,
                        percentageChange: rowState.totalGainPercent,
                        fontSize: theme.textTheme.labelMedium!.fontSize!,
                        useExtendedPeriodString: false,
                      ),
                    ])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
