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
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;
    final selectedRange = ref.watch(userConfigProvider).value?.netWorthRange ?? ChartRangeEnum.oneDay;

    return SproutCard(
      child: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildHeader(netWorthAsync, isPrivate, selectedRange)],
            ),
            netWorthAsync.when(
              data: (data) => SproutLineChart(
                data: HistoricalDataPointExtensions.toMap(data?.timeline ?? []),
                chartRange: selectedRange,
                showYAxis: false,
                height: 125,
                showXAxis: true,
                formatValue: (val) => val.toCurrency(isPrivate),
              ),
              loading: () => const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const SizedBox(height: 250, child: Center(child: Text("Error loading chart"))),
            ),
            ChartRangeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<TotalNetWorthDTO?> async, bool isPrivate, ChartRangeEnum selectedRange) {
    final data = async.value;
    final dataForRange = data?.history.getValueByFrame(selectedRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text("Net Worth", style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
        Text(
          data?.value.toCurrency(isPrivate) ?? "--",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'monospace'),
        ),
        SproutChangeWidget(
          totalChange: dataForRange?.valueChange,
          percentageChange: dataForRange?.percentChange,
          mainAxisAlignment: MainAxisAlignment.start,
          period: selectedRange,
          fontSize: 12,
        ),
      ],
    );
  }
}
