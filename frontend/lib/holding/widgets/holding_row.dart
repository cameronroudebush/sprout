import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/holding_logo.dart';
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
    final livePriceAsync = ref.watch(livePriceProvider(holding.symbol));

    return livePriceAsync.when(
      loading: () => _buildRow(context, ref, holding.marketValue, 0, 0, isLoading: true),
      error: (_, __) => _buildRow(context, ref, holding.marketValue, 0, 0),
      data: (liveData) {
        final livePrice = liveData?.price ?? (holding.marketValue / holding.shares);
        final liveMarketValue = livePrice * holding.shares;

        // Compare Live Value vs Yesterday's Close (stored marketValue)
        final dayValueChange = liveMarketValue - holding.marketValue;
        final dayPercentChange = holding.marketValue != 0 ? (dayValueChange / holding.marketValue) * 100 : 0.0;

        return _buildRow(
          context,
          ref,
          liveMarketValue,
          dayValueChange,
          dayPercentChange,
          isLive: liveData?.marketState == MarketIndexDtoMarketStateEnum.REGULAR,
        );
      },
    );
  }

  /// Builds the content row with our given data
  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    num marketValue,
    num change,
    num percent, {
    bool isLive = false,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

    return InkWell(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
        ),
        child: Row(
          spacing: 12,
          children: [
            // Logo
            HoldingLogo(holding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(holding.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Visual Status Indicator
                  Row(
                    spacing: 4,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLive ? Colors.green : theme.disabledColor,
                        ),
                      ),
                      Text(
                        isLive ? "LIVE" : "PREVIOUS CLOSE",
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.5,
                          color: isLive ? theme.colorScheme.primary : theme.disabledColor,
                          fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  marketValue.toCurrency(isPrivate),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
                    color: isLive ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                SproutChangeWidget(totalChange: change, percentageChange: percent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
