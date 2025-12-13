import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/text.dart';

class SproutPieChart extends StatefulWidget {
  /// The data to display for our chart
  final Map<String, num>? data;

  /// The header to display with this pie chart
  final String header;

  /// Text to display below the header, if necessary
  final String? subheader;

  /// If we should wrap this in a card
  final bool showLegend;

  /// If we should show how the title of that pie slice
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
    this.showLegend = true,
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

/// A generic pie chart that renders the given map
class _SproutPieChartState extends State<SproutPieChart> {
  int touchedIndex = -1;

  /// List of pie chart colors to use
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
  ];

  @override
  Widget build(BuildContext context) {
    final height = widget.height - 50;
    if (widget.data == null || widget.data!.isEmpty) {
      return SizedBox(
        height: height * 1.25,
        width: double.infinity,
        child: Center(child: Text("No data available")),
      );
    }

    final centerSpacingRadius = height / 5;

    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        children: [
          TextWidget(
            referenceSize: 1.5,
            text: widget.header,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (widget.subheader != null) Text(widget.subheader!, style: TextStyle()),
          SizedBox(
            height: height * 1.25,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.showLegend) _buildLegend(),
                Expanded(
                  child: SizedBox(
                    height: height,
                    child: PieChart(
                      PieChartData(
                        sections: _generatePieSections(),
                        centerSpaceRadius: centerSpacingRadius.toDouble(),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });

                            // Handle the tap event
                            if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
                              final index = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                              if (index >= 0 && index < widget.data!.length) {
                                final sortedEntries = widget.data!.entries.sortedBy((entry) => entry.value).toList();

                                final entry = sortedEntries[index];
                                widget.onSliceTap?.call(entry.key, entry.value.toDouble());
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Generates the sections for the pie chart.
  List<PieChartSectionData> _generatePieSections() {
    int i = 0;
    return widget.data!.entries.sortedBy((entry) => entry.value).mapIndexed((index, entry) {
      final color = widget.colorMapping?[entry.key] ?? colors[i % colors.length];
      i++;
      final isTouched = index == touchedIndex;
      final double radius = isTouched ? 70 : 60;
      final double titleFontSize = widget.showPieTitle
          ? isTouched
                ? 16
                : 12
          : isTouched
          ? 16
          : 0;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        // Show a detailed tooltip for the touched section, or just the title for others
        title: isTouched || widget.showPieValue
            ? '${entry.key}\n(${widget.formatValue?.call(entry.value) ?? entry.value})'
            : entry.key,

        radius: radius,
        titleStyle: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  /// Builds the legend for the pie chart.
  Widget _buildLegend() {
    int i = 0;
    return SizedBox(
      width: 128,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: widget.data!.entries.sortedBy((entry) => entry.value).reversed.map((entry) {
                final category = entry.key;
                // Find the corresponding color from the generated pie sections
                final sectionIndex = widget.data!.entries
                    .sortedBy((e) => e.value)
                    .indexWhere((e) => e.key == entry.key);
                final color = sectionIndex != -1
                    ? _generatePieSections()[sectionIndex].color
                    : (widget.colorMapping?[entry.key] ?? colors[i % colors.length]);
                i++;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    spacing: 8,
                    children: [
                      Container(width: 12, height: 12, color: color),
                      Expanded(child: Text(category, softWrap: true)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
