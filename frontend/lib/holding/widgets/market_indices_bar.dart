import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Displays the major market indexes and their current status
class MajorIndicesBarWidget extends ConsumerWidget {
  /// If we should show the price
  final bool showPrice;

  const MajorIndicesBarWidget({super.key, this.showPrice = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(majorIndicesProvider);

    return indicesAsync.when(
      data: (indices) => _buildContent(context, indices, indicesAsync.isRefreshing),
      loading: () => const SproutCard(
        child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (err, _) => const SizedBox.shrink(),
    );
  }

  /// Build the content of the indices to show
  Widget _buildContent(BuildContext context, List<MarketIndexDto> indices, bool isRefreshing) {
    if (indices.isEmpty) return const SizedBox.shrink();

    return SproutCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Take the status only from the first index as a global indicator
                  _StatusBadge(state: indices.first.marketState),
                  const VerticalDivider(width: 32, indent: 8, endIndent: 8),
                  Expanded(child: Row(children: _buildTilesWithSeparators(indices))),
                ],
              ),
            ),
          ),
          if (isRefreshing) const LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent),
        ],
      ),
    );
  }

  /// Builds the tile content to be displayed with separators after it
  List<Widget> _buildTilesWithSeparators(List<MarketIndexDto> indices) {
    List<Widget> items = [];
    for (int i = 0; i < indices.length; i++) {
      items.add(
        Expanded(
          child: _IndexTile(data: indices[i], showPrice: showPrice),
        ),
      );

      if (i < indices.length - 1) {
        items.add(const VerticalDivider(width: 32, indent: 8, endIndent: 8));
      }
    }
    return items;
  }
}

/// Renders a widget of a specific index tile
class _IndexTile extends ConsumerWidget {
  final bool showPrice;
  final MarketIndexDto data;

  const _IndexTile({required this.data, required this.showPrice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

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
            data.price.toCurrency(isPrivate),
            style: theme.textTheme.labelLarge,
          ),
        SproutChangeWidget(
          totalChange: data.change,
          percentageChange: data.changePercent,
          mainAxisAlignment: MainAxisAlignment.center,
          showValue: false,
          fontSize: theme.textTheme.labelLarge!.fontSize!,
        ),
      ],
    );
  }
}

/// The market status badge
class _StatusBadge extends StatelessWidget {
  final MarketIndexDtoMarketStateEnum? state;
  const _StatusBadge({this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = state == MarketIndexDtoMarketStateEnum.REGULAR;
    final color = isLive ? Colors.green : Colors.red;

    String label = "CLOSED";
    if (isLive) label = "LIVE";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("MARKET STATUS", style: theme.textTheme.labelSmall),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [if (isLive) BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)],
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}
