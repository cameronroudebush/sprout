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
  DateTime? _lastRawSelectedDate; // Track the exact raw parent date to catch all increments

  // ANCHOR: Generate target choices relative to the ACTIVE parent baseline date, NOT today's date
  List<DateTime> _getComparisonTargets(DateTime baseline, bool isMonthly) {
    if (isMonthly) {
      return List.generate(12, (index) {
        // Generate the 12 preceding months relative to the inspected month canvas
        return DateTime(baseline.year, baseline.month - index - 1, 1);
      });
    } else {
      return List.generate(5, (index) {
        // Generate preceding fiscal years relative to the inspected year canvas
        return DateTime(baseline.year - index - 1, 1, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMonthly = widget.view == CashFlowView.monthly;

    final baselineDate = widget.selectedDate != null
        ? DateTime(widget.selectedDate!.year, widget.selectedDate!.month, 1)
        : DateTime(DateTime.now().year, DateTime.now().month, 1);

    final bool rawDateChanged = _lastRawSelectedDate != widget.selectedDate;
    final bool viewChanged = _lastView != widget.view;

    final availableTargets = _getComparisonTargets(baselineDate, isMonthly);
    if (viewChanged || rawDateChanged || _customTargetDate == null || !availableTargets.contains(_customTargetDate)) {
      _customTargetDate = availableTargets.first;
      _lastView = widget.view;
      _lastRawSelectedDate = widget.selectedDate;
    }

    final targetYear = _customTargetDate!.year;
    final targetMonth = isMonthly ? _customTargetDate!.month : null;

    final comparisonAsync = ref.watch(cashFlowComparisonTimelineProvider(
      baselineYear: baselineDate.year,
      baselineMonth: isMonthly ? baselineDate.month : null,
      targetYear: targetYear,
      targetMonth: targetMonth,
    ));
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

        final String subheaderText =
            isMonthly ? DateFormat('MMMM yyyy').format(baselineDate) : DateFormat('yyyy').format(baselineDate);

        return SproutLineChart(
          series: series,
          showDateInTooltip: isMonthly ? false : true,
          chartRange: isMonthly ? ChartRangeEnum.oneMonth : ChartRangeEnum.oneYear,
          showXAxis: isMonthly ? false : true,
          showYAxis: true,
          showGrid: true,
          showZeroLine: false,
          showLegend: false,
          header: ChartHeader(
            title: "Spending Trend",
            subheader: subheaderText,
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
