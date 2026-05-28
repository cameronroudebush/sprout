import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';

/// A generic widget that provides spending comparison timeline analyses
class SpendingCompareChart extends ConsumerStatefulWidget {
  final CashFlowView view;
  final DateTime? selectedDate;

  const SpendingCompareChart({
    super.key,
    this.view = CashFlowView.monthly,
    this.selectedDate,
  });

  @override
  ConsumerState<SpendingCompareChart> createState() => _SpendingCompareChartState();
}

class _SpendingCompareChartState extends ConsumerState<SpendingCompareChart> {
  DateTime? _customTargetDate;
  CashFlowView? _lastView;

  List<DateTime> _getLastYearMonths() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      return DateTime(now.year, now.month - index - 1, 1);
    });
  }

  List<DateTime> _getLastFiveYears() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      return DateTime(now.year - index - 1, 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMonthly = widget.view == CashFlowView.monthly;
    final availableTargets = isMonthly ? _getLastYearMonths() : _getLastFiveYears();

    if (_lastView != widget.view || _customTargetDate == null || !availableTargets.contains(_customTargetDate)) {
      _customTargetDate = availableTargets.first;
      _lastView = widget.view;
    }

    final targetYear = _customTargetDate!.year;
    final targetMonth = isMonthly ? _customTargetDate!.month : null;

    final comparisonAsync = ref.watch(cashFlowComparisonTimelineProvider(targetYear, targetMonth));
    final formatter = ref.watch(currencyFormatterProvider);

    return comparisonAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (dto) {
        if (dto == null) return const SizedBox.shrink();

        SproutChartSeries createSeries(List<dynamic> rawData, String label, Color color, bool isDashed) {
          final chartData =
              LineChartDataProcessor.prepareChartData(Map.fromEntries(rawData.map((e) => MapEntry(e.date, e.value))));
          return SproutChartSeries(
            data: chartData,
            label: label,
            config: LineSeriesConfig(color: color, isDashed: isDashed),
          );
        }

        final List<SproutChartSeries> series = [
          createSeries(dto.currentMonthData, dto.currentMonthLabel, Colors.blue, false),
          createSeries(dto.targetMonthData, dto.targetMonthLabel, Colors.grey, true),
        ];

        return SproutLineChart(
          series: series,
          showDateInTooltip: false,
          chartRange: isMonthly ? ChartRangeEnum.oneMonth : ChartRangeEnum.oneYear,
          showXAxis: false,
          showYAxis: true,
          showGrid: true,
          showZeroLine: false,
          showLegend: false,
          header: ChartHeader(
            title: "Spending Trend",
            subheader: series[0].label,
            right: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<DateTime>(
                    isDense: true,
                    padding: EdgeInsets.zero,
                    value: _customTargetDate,
                    items: availableTargets
                        .map((date) => DropdownMenuItem(
                              value: date,
                              child: Text(
                                isMonthly
                                    ? "vs ${DateFormat('MMM yyyy').format(date)}"
                                    : "vs ${DateFormat('yyyy').format(date)}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _customTargetDate = val!),
                  ),
                )
              ],
            ),
          ),
          formatValue: (val) => formatter.format(val),
          formatYAxis: (val) => formatter.format(val, compact: true),
        );
      },
    );
  }
}
