import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/holding_logo.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';

/// This widget shows a specific holding row from an account
class HoldingRow extends ConsumerWidget {
  final Holding holding;
  final bool isSelected;
  final VoidCallback onSelect;

  const HoldingRow({super.key, required this.holding, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);

    final holdingHistoryAsync = ref.watch(accountHoldingHistoryProvider(holding.id));
    final frame = holdingHistoryAsync.value?.getValueByFrame(ChartRangeEnum.oneDay);
    ref.read(batchedLivePricesProvider.notifier).requestSymbol(holding.symbol);
    final livePrices = ref.watch(batchedLivePricesProvider);
    final liveData = livePrices[holding.symbol];

    final livePrice = liveData?.price ?? (holding.marketValue / holding.shares);
    final liveMarketValue = livePrice * holding.shares;

    final dayChange = liveMarketValue - holding.marketValue;
    final dayPercent = holding.marketValue != 0 ? (dayChange / holding.marketValue) * 100 : 0.0;

    final account = ref.watch(
      accountsProvider.select((asyncState) {
        return asyncState.value?.accounts.firstWhereOrNull(
          (a) => a.id == holding.accountId,
        );
      }),
    );

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
            HoldingLogo(holding),

            // Market data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  // Symbol & Total Market Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Text(holding.symbol, style: theme.textTheme.titleMedium),
                        ],
                      ),
                      Text(
                        formatter.format(liveMarketValue),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),

                  // Price Type (Live/Prev) & Price Change
                  if (liveData != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 4,
                          children: [
                            Text(
                              "Intraday Change",
                              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                          totalChange: dayChange,
                          percentageChange: dayPercent,
                          fontSize: theme.textTheme.labelMedium!.fontSize!,
                        ),
                      ],
                    ),

                  // Provider Source
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
                                "This is the most recent change reported by ${account?.provider ?? "Unknown"}. This value updates less often and may lag behind live market movements.",
                            child: Icon(
                              Icons.info_outline,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      if (frame != null)
                        SproutChangeWidget(
                          totalChange: frame.valueChange,
                          percentageChange: frame.percentChange,
                          fontSize: theme.textTheme.labelMedium!.fontSize!,
                          useExtendedPeriodString: false,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
