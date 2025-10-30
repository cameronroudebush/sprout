import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/text.dart';

class SproutPieChart extends StatefulWidget {
  /// The data to display for our chart
  final Map<String, num>? data;

  /// The header to display with this pie chart
  final String header;

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
    this.height = 250,
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
    if (widget.data == null || widget.data!.isEmpty) {
      return SizedBox(
        height: widget.height * 1.25,
        width: double.infinity,
        child: Center(child: Text("No data available")),
      );
    }

    final centerSpacingRadius = widget.height / 5;

    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        children: [
          TextWidget(
            referenceSize: 1.5,
            text: widget.header,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: widget.height * 1.25,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: widget.height,
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
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.showLegend) _buildLegend(),
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
              children: widget.data!.entries.sortedBy((entry) => -entry.value).map((entry) {
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
