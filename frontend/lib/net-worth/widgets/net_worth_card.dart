import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/models/extensions/historical_data_point_extensions.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A generic net worth display that can display a title, the balances, and allow selection of the display timeline
class NetWorthDisplay extends ConsumerWidget {
  /// The title shown in the top-left (e.g., "NET WORTH" or "ACCOUNT BALANCE")
  final String? title;

  /// Current value to display on our card
  final AsyncValue<num?> currentValue;

  /// The DTO containing the maps for valueChange and percentChange
  final AsyncValue<EntityHistory?> historyData;

  /// The list of points used to render the sparkline
  final AsyncValue<List<HistoricalDataPoint>?> timelineData;

  /// If we should inverse the value and percentage changes
  final bool invert;

  const NetWorthDisplay(
      {super.key,
      this.title,
      required this.historyData,
      required this.timelineData,
      required this.currentValue,
      this.invert = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(userConfigProvider).value;
    final isPrivate = config?.privateMode ?? false;
    final selectedRange = config?.netWorthRange ?? ChartRangeEnum.oneDay;

    final frame = historyData.value?.getValueByFrame(selectedRange);
    final currentVal = currentValue.value ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        _buildHeader(context, isPrivate, selectedRange, currentVal, frame),
        // Net worth chart data
        Padding(
            padding: EdgeInsetsGeometry.only(top: 12),
            child: timelineData.when(
              data: (points) => SproutLineChart(
                data: HistoricalDataPointExtensions.toMap(points ?? []),
                chartRange: selectedRange,
                showYAxis: false,
                height: 100,
                showXAxis: true,
                formatValue: (val) => val.toCurrency(isPrivate),
                formatYAxis: (val) => val.toShortCurrency(isPrivate),
              ),
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const SizedBox(height: 100, child: Center(child: Text("Error loading chart"))),
            )),
      ],
    );
  }

  /// Builds the header row that displays net worth information and range selectors
  Widget _buildHeader(
    BuildContext context,
    bool isPrivate,
    ChartRangeEnum range,
    num value,
    EntityHistoryDataPoint? frame,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              value.toCurrency(isPrivate),
              style: theme.textTheme.headlineSmall?.copyWith(color: value.toBalanceColor(theme)),
            ),
            SproutChangeWidget(
                totalChange: frame?.valueChange,
                percentageChange: frame?.percentChange,
                mainAxisAlignment: MainAxisAlignment.start,
                useExtendedPeriodString: false,
                period: range,
                fontSize: 11,
                invert: invert),
          ],
        ),
        ChartRangeSelector(),
      ],
    );
  }
}
