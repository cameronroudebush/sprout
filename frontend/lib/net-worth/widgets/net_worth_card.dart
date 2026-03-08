import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/models/extensions/historical_data_point_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

class NetWorthCard extends ConsumerStatefulWidget {
  const NetWorthCard({super.key});

  @override
  ConsumerState<NetWorthCard> createState() => _NetWorthCardState();
}

class _NetWorthCardState extends ConsumerState<NetWorthCard> {
  @override
  Widget build(BuildContext context) {
    final netWorthAsync = ref.watch(totalNetWorthProvider);
    final config = ref.watch(userConfigProvider).value;
    final isPrivate = config?.privateMode ?? false;
    final selectedRange = config?.netWorthRange ?? ChartRangeEnum.oneDay;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _buildHeader(netWorthAsync, isPrivate, selectedRange),
            // Net worth chart data
            netWorthAsync.when(
              data: (data) => SproutLineChart(
                data: HistoricalDataPointExtensions.toMap(data?.timeline ?? []),
                chartRange: selectedRange,
                showYAxis: false,
                height: 100,
                showXAxis: true,
                formatValue: (val) => val.toCurrency(isPrivate),
              ),
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const SizedBox(height: 100, child: Center(child: Text("Error loading chart"))),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header row that displays net worth information and range selectors
  Widget _buildHeader(AsyncValue<TotalNetWorthDTO?> async, bool isPrivate, ChartRangeEnum selectedRange) {
    final data = async.value;
    final dataForRange = data?.history.getValueByFrame(selectedRange);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              "NET WORTH",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              data?.value.toCurrency(isPrivate) ?? "--",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                // Reduced from headlineMedium
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
            SproutChangeWidget(
              totalChange: dataForRange?.valueChange,
              percentageChange: dataForRange?.percentChange,
              mainAxisAlignment: MainAxisAlignment.start,
              period: selectedRange,
              fontSize: 11, // Slightly smaller font
            ),
          ],
        ),
        ChartRangeSelector(),
      ],
    );
  }
}
