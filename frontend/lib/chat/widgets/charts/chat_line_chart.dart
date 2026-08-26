import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/chat/widgets/charts/chat_chart_utility.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// A specific version of the line chart that processes some JSON chart data from an LLM
///   and builds it into a chart for display within our chat messages
class ChatSproutLineChart extends ConsumerWidget {
  final Map<String, dynamic> chartData;

  /// Date format we expect from the LLM
  final DateFormat _chartDateFormat = DateFormat('MM/dd/yyyy');

  ChatSproutLineChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);

    final rawTitle = chartData['title'] as String?;
    final title = ChatChartUtility.sanitizeChartText(rawTitle, defaultValue: 'Trend Chart');
    final rawSeriesList = chartData['series'] as List<dynamic>? ?? [];
    final chartSeries = parseChartSeries(rawSeriesList, theme);

    // No chart data? Return such
    if (chartSeries.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 350,
      child: SproutLineChart(
        series: chartSeries,
        chartRange: ChartRangeUtility.inferChartRange(chartSeries),
        header: SproutChartHeader(title: title),
        showYAxis: true,
        showXAxis: true,
        showGrid: true,
        showLegend: chartSeries.length > 1,
        formatYAxis: (value) => formatter.format(value, compact: true),
        formatValue: (value) => formatter.format(value),
      ),
    );
  }

  /// Parses raw JSON series data from the LLM into a list of [SproutChartSeries].
  List<SproutChartSeries> parseChartSeries(
    List<dynamic> rawSeriesList,
    ThemeData theme,
  ) {
    final List<SproutChartSeries> chartSeries = [];

    for (int i = 0; i < rawSeriesList.length; i++) {
      final rawSeries = rawSeriesList[i] as Map<String, dynamic>?;
      if (rawSeries == null) continue;

      final rawLabel = rawSeries['label'] as String?;
      final label = ChatChartUtility.sanitizeChartText(rawLabel, defaultValue: 'Series ${i + 1}');
      final dataPoints = rawSeries['data'] as List<dynamic>? ?? [];

      final rawColorStr = rawSeries['color'] as String?;
      final seriesColor = rawColorStr?.toColor;

      final Map<DateTime, double> entries = {};

      for (final dp in dataPoints) {
        if (dp is! Map<String, dynamic>) continue;

        final dateStr = dp['date']?.toString().trim() ?? '';
        final value = (dp['value'] as num?)?.toDouble() ?? 0.0;

        if (dateStr.isNotEmpty) {
          try {
            final parsedDate = _chartDateFormat.parse(dateStr);
            entries[parsedDate] = value;
          } catch (_) {
            // Skip invalid date strings cleanly
          }
        }
      }

      if (entries.isNotEmpty) {
        final processedData = LineChartDataProcessor.prepareChartData(entries);

        chartSeries.add(
          SproutChartSeries(
            label: label,
            data: processedData,
            config: LineSeriesConfig(
              usePositiveNegativeColors: false,
              color: seriesColor,
              showArea: true,
              width: 3.0,
              showInTooltip: true,
            ),
          ),
        );
      }
    }

    return chartSeries;
  }
}
