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
import 'package:sprout/shared/widgets/charts/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A net worth widget that displays the users overall net worth across all accounts with text and a chart
class UserNetWorthWidget extends ConsumerWidget {
  final String? title;
  final bool invert;

  /// If this should be the mobile design
  final bool mobile;

  const UserNetWorthWidget({super.key, this.title = "Net Worth", this.invert = false, this.mobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(totalNetWorthProvider);
    final formatter = ref.watch(currencyFormatterProvider);

    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text("Error loading data")),
      data: (dto) {
        if (dto == null || dto.timeline.isEmpty) {
          return const Center(child: Text("Start adding accounts to view your net worth"));
        }

        final config = ref.watch(userConfigProvider).value;
        final selectedRange = config?.netWorthRange ?? ChartRangeEnum.oneDay;

        final history = dto.history;
        final timeline = dto.timeline;
        final frame = history.getValueByFrame(selectedRange);

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

        if (processedChartData.spots.isNotEmpty && !mobile) {
          chartSeriesList.add(LineChartDataProcessor.computeAverageData(processedChartData));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: [
            Padding(
                padding: mobile ? EdgeInsetsGeometry.symmetric(horizontal: 4, vertical: 4) : EdgeInsetsGeometry.zero,
                child: UserNetWorthText(
                  range: selectedRange,
                  frame: frame,
                  showRangeSelector: !mobile,
                )),
            Expanded(
              child: SproutLineChart(
                series: chartSeriesList,
                chartRange: selectedRange,
                showYAxis: !mobile,
                showXAxis: !mobile,
                showGrid: !mobile,
                showLegend: false,
                showZeroLine: false,
                showBorder: !mobile,
                padding: mobile ? EdgeInsets.zero : null,
                formatValue: (val) => formatter.format(val),
                formatYAxis: (val) => formatter.format(val, compact: true),
              ),
            ),
            if (mobile)
              const Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 2, vertical: 4),
                  child: ChartRangeSelector(large: true))
          ],
        );
      },
    );
  }
}
