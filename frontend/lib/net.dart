import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/api/transaction.dart';
import 'package:sprout/model/net.worth.dart';
import 'package:sprout/utils/formatters.dart';
import 'package:sprout/widgets/text.dart';

enum ChartRange { sevenDays, thirtyDays, oneYear }

class NetWorthWidget extends StatefulWidget {
  const NetWorthWidget({super.key});

  @override
  State<NetWorthWidget> createState() => _NetWorthWidgetState();
}

class _NetWorthWidgetState extends State<NetWorthWidget> {
  double _currentNetWorth = 0;
  NetWorthOverTime? _netWorthOT;
  bool _isLoading = true;
  String? _errorMessage;
  ChartRange _selectedChartRange = ChartRange.sevenDays;

  @override
  void initState() {
    super.initState();
    _setNetWorth();
  }

  Future<void> _setNetWorth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final transactionAPI = Provider.of<TransactionAPI>(context, listen: false);
      _currentNetWorth = await transactionAPI.getNetWorth();
      _netWorthOT = await transactionAPI.getNetWorthOT();
    } catch (e) {
      _errorMessage = 'Failed to load net worth: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final Map<DateTime, double> filteredHistoricalData =
        _netWorthOT?.historicalData.entries
            .where((entry) {
              final cutoffDate = DateTime.now().subtract(_getDurationForRange(_selectedChartRange));
              return entry.key.isAfter(cutoffDate) || entry.key.isAtSameMomentAs(cutoffDate);
            })
            .map((entry) => MapEntry(entry.key, entry.value))
            .toList()
            .cast<MapEntry<DateTime, double>>()
            .fold<Map<DateTime, double>>({}, (map, entry) {
              map[entry.key] = entry.value;
              return map;
            }) ??
        {};

    final sortedChartEntries = filteredHistoricalData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final chartSpots = sortedChartEntries
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    return Consumer<AccountProvider>(
      builder: (context, authProvider, child) {
        return Center(
          child: Card(
            elevation: 6.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _isLoading
                  ? const SizedBox(height: 350, child: Center(child: CircularProgressIndicator()))
                  : _errorMessage != null
                  ? SizedBox(
                      height: 350,
                      child: Center(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextWidget(referenceSize: 1, text: 'Current Net Worth'),
                        const SizedBox(height: 10.0),
                        TextWidget(
                          referenceSize: 2.5,
                          text: currencyFormatter.format(_currentNetWorth),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentNetWorth >= 0 ? Colors.green : colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        TextWidget(referenceSize: 1, text: 'Net Worth Trend'),
                        const SizedBox(height: 16.0),
                        _buildChartRangeSelector(theme, colorScheme),
                        _netWorthOT != null && sortedChartEntries.isNotEmpty
                            ? SizedBox(
                                height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
                                  child: LineChart(
                                    _buildNetWorthChartData(
                                      chartSpots,
                                      sortedChartEntries,
                                      theme,
                                      colorScheme,
                                      screenWidth,
                                    ),
                                    duration: Duration(milliseconds: 0),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No historical data available for this period.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartRangeSelector(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: ToggleButtons(
        isSelected: ChartRange.values.map((range) => range == _selectedChartRange).toList(),
        onPressed: (int index) => setState(() => _selectedChartRange = ChartRange.values[index]),
        borderRadius: BorderRadius.circular(8.0),
        selectedColor: colorScheme.onPrimary,
        fillColor: colorScheme.primary,
        color: colorScheme.primary,
        borderColor: colorScheme.primary.withValues(alpha: 0.5),
        selectedBorderColor: colorScheme.primary,
        constraints: const BoxConstraints(minHeight: 36.0, minWidth: 80.0),
        children: ChartRange.values
            .map(
              (range) => Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .025),
                child: TextWidget(
                  referenceSize: 1,
                  text: range.name
                      .replaceAll('sevenDays', '7 Days')
                      .replaceAll('thirtyDays', '30 Days')
                      .replaceAll('oneYear', '1 Year'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  LineChartData _buildNetWorthChartData(
    List<FlSpot> spots,
    List<MapEntry<DateTime, double>> sortedEntries,
    ThemeData theme,
    ColorScheme colorScheme,
    double screenWidth,
  ) {
    if (spots.isEmpty) {
      return LineChartData(
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineBarsData: [],
      );
    }

    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    // Adjust min/max Y to prevent line from touching border
    minY = minY > 0 ? minY * 0.95 : minY * 1.05;
    maxY = maxY < 0 ? maxY * 0.95 : maxY * 1.05;

    // Dynamically adjust font size for X-axis labels
    double xLabelFontSize;
    if (_selectedChartRange == ChartRange.oneYear) {
      xLabelFontSize = screenWidth < 400 ? 8.0 : 10.0;
    } else if (_selectedChartRange == ChartRange.thirtyDays) {
      xLabelFontSize = screenWidth < 400 ? 9.0 : 11.0;
    } else {
      xLabelFontSize = 10.0;
    }

    // Determine the Y axis text size
    double yReservedSize = 40;
    if (maxY > 100000) {
      yReservedSize = 80;
    } else if (maxY > 100000000) {
      yReservedSize = 120;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: colorScheme.primary.withValues(alpha: 0.3), strokeWidth: 0.5),
        getDrawingVerticalLine: (value) => FlLine(color: colorScheme.primary.withValues(alpha: 0.3), strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            maxIncluded: false,
            minIncluded: false,
            reservedSize: 30,
            getTitlesWidget: (value, metaTitle) {
              if (value.toInt() < sortedEntries.length) {
                final date = sortedEntries[value.toInt()].key;
                String format;
                switch (_selectedChartRange) {
                  case ChartRange.sevenDays:
                    format = 'EEE';
                    break;
                  case ChartRange.thirtyDays:
                    format = 'MMM dd';
                    break;
                  case ChartRange.oneYear:
                    format = 'MMM yy';
                    break;
                }
                return SideTitleWidget(
                  fitInside: SideTitleFitInsideData.fromTitleMeta(metaTitle),
                  meta: metaTitle,
                  child: Text(
                    DateFormat(format).format(date),
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface, fontSize: xLabelFontSize),
                  ),
                );
              }
              return const Text('');
            },
            interval: _getChartInterval(spots.length),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: yReservedSize,
            minIncluded: false,
            maxIncluded: false,
            getTitlesWidget: (value, metaTitle) {
              return SideTitleWidget(
                fitInside: SideTitleFitInsideData.fromTitleMeta(metaTitle),
                meta: metaTitle,
                child: Text(
                  currencyFormatter.format(value),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                ),
              );
            },
            interval: _getChartValueInterval(minY, maxY),
          ),
        ),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: colorScheme.outline, width: 1)),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot.bar.spots[barSpot.spotIndex];
              if (flSpot.x.toInt() < sortedEntries.length) {
                final date = sortedEntries[flSpot.x.toInt()].key;
                return LineTooltipItem(
                  '${DateFormat('MMM dd, yyyy').format(date)}\n',
                  TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: currencyFormatter.format(flSpot.y),
                      style: TextStyle(
                        color: flSpot.y >= 0 ? colorScheme.primary : colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }
              return null;
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  Duration _getDurationForRange(ChartRange range) {
    switch (range) {
      case ChartRange.sevenDays:
        return const Duration(days: 7);
      case ChartRange.thirtyDays:
        return const Duration(days: 30);
      case ChartRange.oneYear:
        return const Duration(days: 365);
    }
  }

  double _getChartInterval(int numberOfSpots) {
    if (_selectedChartRange == ChartRange.sevenDays) {
      return 1;
    } else if (_selectedChartRange == ChartRange.thirtyDays) {
      return 6;
    } else if (_selectedChartRange == ChartRange.oneYear) {
      return 75;
    }
    return 30; // Fallback
  }

  double _getChartValueInterval(double minY, double maxY) {
    final double diff = (maxY - minY).abs();
    if (diff <= 10) return 2;
    if (diff <= 50) return 10;
    if (diff <= 100) return 20;
    if (diff <= 500) return 100;
    if (diff <= 1000) return 200;
    if (diff <= 5000) return 1000;
    if (diff <= 10000) return 2000;
    if (diff <= 25000) return 5000;
    if (diff <= 50000) return 10000;
    if (diff <= 100000) return 20000;
    if (diff <= 250000) return 50000;
    if (diff <= 500000) return 100000;
    if (diff <= 1000000) return 200000;
    return 500000;
  }
}
