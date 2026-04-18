import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/holding_logo.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/user/user_config_provider.dart';

/// This widget shows a specific holding row from an account
class HoldingRow extends ConsumerWidget {
  final Holding holding;
  final bool isSelected;
  final VoidCallback onSelect;

  const HoldingRow({super.key, required this.holding, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(userConfigProvider).value;
    final isPrivate = config?.privateMode ?? false;
    final userChartRange = config?.netWorthRange ?? ChartRangeEnum.oneDay;

    final holdingHistoryAsync = ref.watch(accountHoldingHistoryProvider(holding.id));
    final frame = holdingHistoryAsync.value?.getValueByFrame(userChartRange);
    final livePriceAsync = ref.watch(livePriceProvider(holding.symbol));
    final liveData = livePriceAsync.value;

    final livePrice = liveData?.price ?? (holding.marketValue / holding.shares);
    final liveMarketValue = livePrice * holding.shares;

    final dayChange = liveMarketValue - holding.marketValue;
    final dayPercent = holding.marketValue != 0 ? (dayChange / holding.marketValue) * 100 : 0.0;
    final isLive = liveData?.marketState == MarketIndexDtoMarketStateEnum.REGULAR;

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
                        liveMarketValue.toCurrency(isPrivate),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),

                  // Price Type (Live/Prev) & Price Change
                  if (liveData != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isLive ? 'Price' : 'Previous Close',
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        SproutChangeWidget(
                            totalChange: dayChange,
                            percentageChange: dayPercent,
                            fontSize: theme.textTheme.labelMedium!.fontSize!,
                            useExtendedPeriodString: false,
                            period: ChartRangeEnum.oneDay),
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
                            "Source: ${holding.account.provider}",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          Tooltip(
                            message: "This data may be out of date",
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
                            period: userChartRange),
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
