import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/card.dart';

/// Displays portfolio and market performance.
class MarketSnapshotBarWidget extends ConsumerWidget {
  /// If we should show the price
  final bool showPrice;

  const MarketSnapshotBarWidget({super.key, this.showPrice = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(majorIndicesProvider);
    final portfolioAsync = ref.watch(portfolioSummaryProvider);

    return indicesAsync.when(
      data: (indices) => _buildContent(
        context,
        indices,
        portfolioAsync.value,
        indicesAsync.isRefreshing || portfolioAsync.isRefreshing,
      ),
      loading: () => const SproutCard(
        child: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (err, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<MarketIndexDto> indices,
    PortfolioSummaryDto? portfolio,
    bool isRefreshing,
  ) {
    if (indices.isEmpty) return const SizedBox.shrink();

    return SproutCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _PortfolioChangeTile(summary: portfolio),
                  ),
                  const VerticalDivider(width: 24, indent: 8, endIndent: 8),
                  ..._buildTilesWithSeparators(indices),
                ],
              ),
            ),
          ),
          if (isRefreshing)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
          Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 6),
            child: (portfolio?.pendingNavSymbols.isNotEmpty ?? false)
                ? Row(
                    children: [
                      _StatusBadge(state: indices.first.marketState),
                      const Spacer(),
                      Text(
                        "Some NAVs are still pending",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.amber.shade700,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                    ],
                  )
                : Center(
                    child: _StatusBadge(state: indices.first.marketState),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTilesWithSeparators(List<MarketIndexDto> indices) {
    final items = <Widget>[];
    for (int i = 0; i < indices.length; i++) {
      items.add(
        Expanded(
          flex: 2,
          child: _IndexTile(data: indices[i], showPrice: showPrice),
        ),
      );

      if (i < indices.length - 1) {
        items.add(const VerticalDivider(width: 16, indent: 8, endIndent: 8));
      }
    }
    return items;
  }
}

/// Displays overall portfolio daily change.
class _PortfolioChangeTile extends ConsumerWidget {
  final PortfolioSummaryDto? summary;

  const _PortfolioChangeTile({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dayChange = summary?.dayChange ?? 0;
    final changeColor = dayChange >= 0 ? Colors.green : theme.colorScheme.error;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 2,
      children: [
        Text("Portfolio", style: theme.textTheme.labelLarge),
        Text(
          summary == null
              ? "—"
              : "${dayChange >= 0 ? "+" : ""}${summary!.dayChangePercent.toStringAsFixed(2)}%",
          style: theme.textTheme.titleSmall?.copyWith(
            color: changeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Renders a widget of a specific index tile.
class _IndexTile extends ConsumerWidget {
  final bool showPrice;
  final MarketIndexDto data;

  const _IndexTile({required this.data, required this.showPrice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 2,
      children: [
        Text(
          data.name,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (showPrice)
          Text(
            formatter.format(data.price),
            style: theme.textTheme.labelLarge,
          ),
        SproutChangeWidget(
          totalChange: data.change,
          percentageChange: data.changePercent * 100,
          mainAxisAlignment: MainAxisAlignment.center,
          showValue: false,
          fontSize: theme.textTheme.labelMedium!.fontSize!,
        ),
      ],
    );
  }
}

/// The market status badge.
class _StatusBadge extends StatelessWidget {
  final MarketIndexDtoMarketStateEnum? state;
  const _StatusBadge({this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = state == MarketIndexDtoMarketStateEnum.REGULAR;
    final color = isLive ? Colors.green : Colors.red;
    final label = isLive ? "LIVE" : "CLOSED";

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text("Market", style: theme.textTheme.labelSmall),
        Padding(
          padding: EdgeInsets.only(left: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                if (isLive)
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
              ],
            ),
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
