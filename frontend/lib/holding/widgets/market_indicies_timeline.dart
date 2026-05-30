import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';

/// A widget that displays a 7-day comparative history chart for the major market indices
class MajorIndicesTimelineWidget extends ConsumerWidget {
  final String? title;

  const MajorIndicesTimelineWidget({super.key, this.title = "Market Performance"});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineDataAsync = ref.watch(majorIndicesTimelineProvider);

    return timelineDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error loading market timelines: $e")),
      data: (indexList) {
        if (indexList.isEmpty) {
          return const Center(child: Text("No market data available"));
        }
        final selectedRange = ChartRangeEnum.sevenDays;
        final List<SproutChartSeries> chartSeriesList = [];

        for (final indexDto in indexList) {
          final timeline = indexDto.timeline;
          if (timeline.isEmpty) continue;
          final Map<DateTime, double> percentageMappedData = {
            for (final point in timeline) point.date: point.changePercent.toDouble(),
          };
          final processedChartData = LineChartDataProcessor.prepareChartData(percentageMappedData);
          final lineColor = indexDto.color.toColor;

          chartSeriesList.add(
            SproutChartSeries(
              data: processedChartData,
              label: indexDto.name,
              config: LineSeriesConfig(
                color: lineColor,
              ),
            ),
          );
        }

        return SproutLineChart(
          series: chartSeriesList,
          chartRange: selectedRange,
          header: ChartHeader(
            title: title,
          ),
          showYAxis: true,
          showXAxis: true,
          showGrid: true,
          showLegend: true,
          showZeroLine: false,
          formatValue: (val) => "${val.toStringAsFixed(2)}%",
          formatYAxis: (val) => "${val.toStringAsFixed(1)}%",
        );
      },
    );
  }
}
