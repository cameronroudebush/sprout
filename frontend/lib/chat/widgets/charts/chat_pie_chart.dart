import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/chat/widgets/charts/chat_chart_utility.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// A pie chart component that parses LLM JSON payloads for display inside chat messages.
class ChatSproutPieChart extends ConsumerWidget {
  final Map<String, dynamic> chartData;

  const ChatSproutPieChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);

    final rawTitle = chartData['title'] as String?;
    final title = ChatChartUtility.sanitizeChartText(rawTitle, defaultValue: 'Breakdown');

    final rawData = chartData['data'] as Map<String, dynamic>? ?? {};
    final rawColors = chartData['colors'] as Map<String, dynamic>? ?? {};

    if (rawData.isEmpty) return const SizedBox.shrink();

    final Map<String, double> parsedData = {};
    final Map<String, Color> colorMapping = {};

    int index = 0;
    rawData.forEach((key, value) {
      final cleanKey = ChatChartUtility.sanitizeChartText(key, defaultValue: 'Item ${index + 1}');
      final doubleVal = (value as num?)?.toDouble().abs() ?? 0.0;

      if (doubleVal > 0) {
        parsedData[cleanKey] = doubleVal;
        final colorStr = rawColors[key] as String? ?? rawColors[cleanKey] as String?;
        colorMapping[cleanKey] = colorStr?.toColor ?? Colors.grey;
      }
      index++;
    });

    if (parsedData.isEmpty) return const SizedBox.shrink();

    final itemCount = parsedData.length;
    final double computedHeight = (200.0 + (itemCount * 24.0)).clamp(220.0, 450.0);

    return SizedBox(
      height: computedHeight,
      child: SproutPieChart(
        data: parsedData,
        colorMapping: colorMapping,
        header: SproutChartHeader(title: title),
        legendPosition: SproutChartLegendPosition.bottom,
        showPieValue: false,
        showPieTitle: false,
        formatValue: (val) => formatter.format(val),
      ),
    );
  }
}
