import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/models/extensions/historical_data_point_extensions.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/amount_change.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A generic net worth display that accepts any Data Transfer Object (DTO)
/// and uses mapping functions to extract the required fields for the chart.
class GenericNetWorthWidget<T> extends ConsumerWidget {
  final String? title;

  /// A unified AsyncValue containing your backend model (e.g. TotalNetWorthDTO)
  final AsyncValue<T?> data;

  /// Mapping functions to extract the required chart data from your model
  final num Function(T data) getValue;
  final EntityHistory? Function(T data) getHistory;
  final List<HistoricalDataPoint>? Function(T data) getTimeline;

  final bool invert;
  final double chartHeight;

  const GenericNetWorthWidget({
    super.key,
    this.title,
    required this.data,
    required this.getValue,
    required this.getHistory,
    required this.getTimeline,
    this.invert = false,
    this.chartHeight = 180,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return data.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SizedBox(height: 200, child: Center(child: Text("Error loading data"))),
      data: (dto) {
        if (dto == null) {
          return const SizedBox(height: 200, child: Center(child: Text("No data available")));
        }

        final config = ref.watch(userConfigProvider).value;
        final selectedRange = config?.netWorthRange ?? ChartRangeEnum.oneDay;
        final formatter = ref.watch(currencyFormatterProvider);

        // Extract the data using the provided mapping functions
        final currentVal = getValue(dto);
        final history = getHistory(dto);
        final timeline = getTimeline(dto) ?? [];
        final frame = history?.getValueByFrame(selectedRange);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _buildHeader(context, formatter, selectedRange, currentVal, frame),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SproutLineChart(
                data: HistoricalDataPointExtensions.toMap(timeline),
                chartRange: selectedRange,
                showYAxis: true,
                height: chartHeight,
                showXAxis: true,
                showGrid: true,
                formatValue: (val) => formatter.format(val),
                formatYAxis: (val) => formatter.format(val, compact: true),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the header row that displays net worth information and range selectors
  Widget _buildHeader(
    BuildContext context,
    CurrencyFormatter formatter,
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
              formatter.format(value),
              style: theme.textTheme.headlineSmall?.copyWith(color: value.toBalanceColor(theme)),
            ),
            SproutChangeWidget(
              totalChange: frame?.valueChange,
              percentageChange: frame?.percentChange,
              mainAxisAlignment: MainAxisAlignment.start,
              useExtendedPeriodString: false,
              period: range,
              fontSize: 11,
              invert: invert,
            ),
          ],
        ),
        const ChartRangeSelector(),
      ],
    );
  }
}
