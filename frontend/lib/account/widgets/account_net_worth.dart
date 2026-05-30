import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/widgets/account_details.dart';
import 'package:sprout/account/widgets/account_net_worth_text.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/models/extensions/historical_data_point_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Widget that shows the account value over time
class AccountNetWorthWidget extends ConsumerWidget {
  final Account account;
  final AsyncValue<AccountChartData> combinedData;

  const AccountNetWorthWidget({
    super.key,
    required this.account,
    required this.combinedData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);

    return combinedData.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => const SizedBox(height: 200, child: Center(child: Text("Error loading account chart data"))),
      data: (chartData) {
        final config = ref.watch(userConfigProvider).value;
        final selectedRange = config?.netWorthRange ?? ChartRangeEnum.oneDay;

        final history = chartData.history;
        final timeline = chartData.timeline ?? [];
        final frame = history?.getValueByFrame(selectedRange);

        final mappedData = HistoricalDataPointExtensions.toMap(timeline);
        final filteredHistorical = LineChartDataProcessor.filterHistoricalData(mappedData, selectedRange);
        final processedChartData = LineChartDataProcessor.prepareChartData(filteredHistorical);

        final List<SproutChartSeries> chartSeriesList = [
          SproutChartSeries(
            data: processedChartData,
            label: account.name,
            config: LineSeriesConfig(
              color: account.isDebt ? theme.colorScheme.error : theme.colorScheme.primary,
              usePositiveNegativeColors: !account.isDebt,
            ),
          ),
        ];

        if (processedChartData.spots.isNotEmpty) {
          chartSeriesList.add(LineChartDataProcessor.computeAverageData(processedChartData));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            AccountNetWorthText(
              account: account,
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
            )),
          ],
        );
      },
    );
  }
}
