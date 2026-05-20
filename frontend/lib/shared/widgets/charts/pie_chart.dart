import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum PieLegendPosition { left, right, bottom, none }

class SproutPieChart extends StatefulWidget {
  /// The data to display for our chart
  final Map<String, num>? data;

  /// The header to display with this pie chart
  final String header;

  /// Text to display below the header, if necessary
  final String? subheader;

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

  final double height;

  const SproutPieChart({
    super.key,
    required this.data,
    required this.header,
    this.legendPosition = PieLegendPosition.right,
    this.showPieTitle = true,
    this.showPieValue = false,
    this.colorMapping,
    this.formatValue,
    this.onSliceTap,
    this.height = 250,
    this.subheader,
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
    final theme = Theme.of(context);
    final chartAreaHeight = widget.height - 60;

    if (widget.data == null || widget.data!.isEmpty) {
      return SizedBox(height: widget.height, child: const Center(child: Text("No data available")));
    }

    /// The chart is wrapped in a SizedBox with an explicit height/width
    /// to maintain a square aspect ratio and prevent layout stretching.
    Widget chart = SizedBox(
      height: chartAreaHeight,
      width: chartAreaHeight,
      child: PieChart(
        PieChartData(
          sections: _generatePieSections(),
          centerSpaceRadius: chartAreaHeight / 5,
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
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(widget.header, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (widget.subheader != null)
          Text(widget.subheader!, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 16),
        Center(
            child: IntrinsicWidth(
                child: widget.legendPosition == PieLegendPosition.bottom
                    ? Column(children: [chart, const SizedBox(height: 12), _buildLegend()])
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.legendPosition == PieLegendPosition.left)
                            Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: _buildLegend(),
                            ),
                          Flexible(
                            child: chart,
                          ),
                          if (widget.legendPosition == PieLegendPosition.right)
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: _buildLegend(),
                            ),
                        ],
                      )))
      ]),
    );
  }

  /// Generates the sections for the pie chart.
  /// Filters out 0-value items to prevent NaN rendering errors in the painting engine.
  List<PieChartSectionData> _generatePieSections() {
    int i = 0;
    return widget.data!.entries.where((e) => e.value > 0).sortedBy((e) => e.value).mapIndexed((index, entry) {
      final isTouched = index == touchedIndex;
      return PieChartSectionData(
        color: widget.colorMapping?[entry.key] ?? colors[i++ % colors.length],
        value: entry.value.toDouble(),
        title: (isTouched || widget.showPieValue)
            ? '${entry.key}\n(${widget.formatValue?.call(entry.value) ?? entry.value})'
            : (widget.showPieTitle ? entry.key : ' '),
        radius: isTouched ? 75 : 60,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : (widget.showPieTitle ? 12 : 0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  /// Builds the legend, utilizing TextOverflow.ellipsis to handle long labels
  /// and prevent Row layout overflows.
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
                decoration: BoxDecoration(color: color, shape: isOthers ? BoxShape.rectangle : BoxShape.circle)),
            const SizedBox(width: 8),
            Text(entry.key, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }).toList();

    return widget.legendPosition == PieLegendPosition.bottom
        ? Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 8, children: legendItems)
        : Padding(
            padding: EdgeInsets.zero,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: legendItems),
          );
  }
}
