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
    final mediaQuery = MediaQuery.of(context);

    if (widget.data == null || widget.data!.isEmpty) {
      return Center(child: TextWidget(text: "No data available"));
    }

    final centerSpacingRadius = mediaQuery.size.height > 1200 ? 15 : widget.height / 15;

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
            height: widget.height,
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
    return widget.data!.entries.mapIndexed((index, entry) {
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
        title: isTouched ? '${entry.key}\n(${widget.formatValue?.call(entry.value) ?? entry.value})' : entry.key,

        radius: radius,
        titleStyle: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  /// Builds the legend for the pie chart.
  Widget _buildLegend() {
    int i = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.data!.entries.map((entry) {
        final category = entry.key;
        final color = colors[i % colors.length];
        i++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, color: color),
              const SizedBox(width: 8),
              Text(category),
            ],
          ),
        );
      }).toList(),
    );
  }
}
