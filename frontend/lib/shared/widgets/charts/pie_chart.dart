import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/charts/models/color.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/util/layout.dart';

/// A generic, configurable pie chart to use across Sprout
class SproutPieChart extends StatefulWidget {
  /// The data to display for our chart
  final Map<String, num>? data;
  final Widget? header;

  /// Determines where the legend is positioned, or if it is hidden entirely using [SproutChartLegendPosition.none]
  final SproutChartLegendPosition legendPosition;

  /// If we should show the title of the pie slice directly on the chart
  final bool showPieTitle;

  /// If we should show the value of that pie slice
  final bool showPieValue;

  /// An optional mapping of colors to use for specific keys in the data.
  final Map<String, Color>? colorMapping;

  /// An optional function to format the value displayed in the pie chart section title.
  final String Function(num value)? formatValue;

  /// Fired when a slice is clicked
  final void Function(String slice, double value)? onSliceTap;

  const SproutPieChart({
    super.key,
    required this.data,
    this.header,
    this.legendPosition = SproutChartLegendPosition.right,
    this.showPieTitle = true,
    this.showPieValue = false,
    this.colorMapping,
    this.formatValue,
    this.onSliceTap,
  });

  @override
  State<SproutPieChart> createState() => _SproutPieChartState();
}

class _SproutPieChartState extends State<SproutPieChart> {
  int touchedIndex = -1;
  late SproutChartColorResolver _colorResolver;

  @override
  void initState() {
    super.initState();
    _colorResolver = SproutChartColorResolver(colorMapping: widget.colorMapping);
  }

  @override
  void didUpdateWidget(covariant SproutPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colorMapping != widget.colorMapping) {
      _colorResolver = SproutChartColorResolver(colorMapping: widget.colorMapping);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartData = widget.data ?? {};

    return SproutChartLayoutFrame(
      header: widget.header,
      data: chartData,
      legendPosition: widget.legendPosition,
      colorResolver: _colorResolver,
      chartArea: LayoutBuilder(
        builder: (context, constraints) {
          final shortestSide =
              constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
          final chartDimension = shortestSide.isFinite && shortestSide > 0 ? shortestSide : 160.0;

          return Center(
            child: SizedBox(
              height: chartDimension,
              width: chartDimension,
              child: PieChart(
                PieChartData(
                  sections: _generatePieSections(chartDimension, chartData),
                  centerSpaceRadius: chartDimension / 4.5,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions || pieTouchResponse?.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                      });

                      if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
                        final sortedEntries = chartData.entries.sortedBy((e) => e.value).toList();
                        final entry = sortedEntries[touchedIndex];
                        widget.onSliceTap?.call(entry.key, entry.value.toDouble());
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(double chartSize, Map<String, num> chartData) {
    final double baseRadius = chartSize * 0.22;

    return chartData.entries.where((e) => e.value > 0).sortedBy((e) => e.value).mapIndexed((index, entry) {
      final isTouched = index == touchedIndex;
      final formattedVal = widget.formatValue?.call(entry.value) ?? entry.value.toString();

      return PieChartSectionData(
        color: _colorResolver.resolve(entry.key),
        value: entry.value.toDouble(),
        radius: isTouched ? baseRadius * 1.15 : baseRadius,
        showTitle: !isTouched && widget.showPieTitle,
        title: widget.showPieValue ? formattedVal : entry.key,
        titleStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        badgePositionPercentageOffset: 0.9,
        badgeWidget: isTouched
            ? Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColorDark,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      '${entry.key}\n$formattedVal',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              )
            : null,
      );
    }).toList();
  }
}
