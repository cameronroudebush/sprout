import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/models/extensions/historical_data_point_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/user_net_worth_text.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A net worth widget that displays the users overall net worth across all accounts with text and a chart
class UserNetWorthWidget extends ConsumerWidget {
  final String? title;
  final bool invert;

  const UserNetWorthWidget({super.key, this.title = "Net Worth", this.invert = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(totalNetWorthProvider);
    final formatter = ref.watch(currencyFormatterProvider);

    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text("Error loading data")),
      data: (dto) {
        if (dto?.value == null) return const Center(child: Text("No data available"));

        final config = ref.watch(userConfigProvider).value;
        final selectedRange = config?.netWorthRange ?? ChartRangeEnum.oneDay;

        final history = dto?.history;
        final timeline = dto?.timeline ?? [];
        final frame = history?.getValueByFrame(selectedRange);

        final mappedData = HistoricalDataPointExtensions.toMap(timeline);
        final filteredHistorical = LineChartDataProcessor.filterHistoricalData(mappedData, selectedRange);
        final processedChartData = LineChartDataProcessor.prepareChartData(filteredHistorical);

        final List<SproutChartSeries> chartSeriesList = [
          SproutChartSeries(
            data: processedChartData,
            label: "Net Worth",
            config: LineSeriesConfig(usePositiveNegativeColors: true),
          ),
        ];

        if (processedChartData.spots.isNotEmpty) {
          chartSeriesList.add(LineChartDataProcessor.computeAverageData(processedChartData));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: [
            UserNetWorthText(
              range: selectedRange,
              frame: frame,
            ),
            Expanded(
              child: SproutLineChart(
                series: chartSeriesList,
                chartRange: selectedRange,
                showYAxis: true,
                showXAxis: true,
                showGrid: true,
                showLegend: false,
                showZeroLine: false,
                formatValue: (val) => formatter.format(val),
                formatYAxis: (val) => formatter.format(val, compact: true),
              ),
            ),
          ],
        );
      },
    );
  }
}
