import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum PieLegendPosition { left, right, bottom, none }

class SproutPieChart extends StatefulWidget {
  /// The data to display for our chart
  final Map<String, num>? data;
  final Widget? header;

  /// Determines where the legend is positioned, or if it is hidden entirely using [PieLegendPosition.none]
  final PieLegendPosition legendPosition;

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
    this.legendPosition = PieLegendPosition.right,
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

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.brown,
    Colors.deepPurple,
    Colors.amber,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) widget.header!,
          const SizedBox(height: 12),
          Expanded(
            child: widget.legendPosition == PieLegendPosition.bottom
                ? Column(
                    children: [
                      Expanded(child: _buildResponsiveChartArea()),
                      const SizedBox(height: 12),
                      _buildLegend(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.legendPosition == PieLegendPosition.left)
                        SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: _buildLegend(),
                            )),
                      Expanded(child: _buildResponsiveChartArea()),
                      if (widget.legendPosition == PieLegendPosition.right)
                        SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: _buildLegend(),
                            )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Measures the real remaining space to prevent overlaying headers or legends
  Widget _buildResponsiveChartArea() {
    return LayoutBuilder(
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
                sections: _generatePieSections(chartDimension),
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
                      final sortedEntries = widget.data!.entries.sortedBy((e) => e.value).toList();
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
    );
  }

  /// Generates the sections for the pie chart using proportional constraints
  List<PieChartSectionData> _generatePieSections(double chartSize) {
    int i = 0;
    // Base thickness calculation for standard rings
    final double baseRadius = chartSize * 0.22;

    return widget.data!.entries.where((e) => e.value > 0).sortedBy((e) => e.value).mapIndexed((index, entry) {
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        color: widget.colorMapping?[entry.key] ?? colors[i++ % colors.length],
        value: entry.value.toDouble(),
        radius: isTouched ? baseRadius * 1.15 : baseRadius,
        title: (isTouched || widget.showPieValue)
            ? '${entry.key}\n(${widget.formatValue?.call(entry.value) ?? entry.value})'
            : (widget.showPieTitle ? entry.key : ' '),
        titleStyle: TextStyle(
          fontSize: isTouched ? 12 : (widget.showPieTitle ? 10 : 0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  /// Builds the legend
  Widget _buildLegend() {
    final entries = widget.data!.entries.sorted((a, b) {
      if (a.key.startsWith("+")) return 1;
      if (b.key.startsWith("+")) return -1;
      return b.value.compareTo(a.value);
    });

    final legendItems = entries.map((entry) {
      final isOthers = entry.key.startsWith("+");
      final color = widget.colorMapping?[entry.key] ?? Colors.grey;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: isOthers ? BoxShape.rectangle : BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(entry.key, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }).toList();

    return widget.legendPosition == PieLegendPosition.bottom
        ? Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 6, children: legendItems)
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: legendItems);
  }
}
