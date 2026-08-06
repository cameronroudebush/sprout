import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// Renders the projected loan amortization over time based on actual balance history
class CashFlowLoanAmortizationChart extends ConsumerWidget {
  final SproutChartHeader? header;

  const CashFlowLoanAmortizationChart({
    super.key,
    this.header,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionsAsync = ref.watch(loanAmortizationProjectionsProvider);
    final formatter = ref.watch(currencyFormatterProvider);

    return projectionsAsync.whenDefault(
      emptyWidget: const Center(
        child: Text(
          "No loan projection data available.\n You must have a 'Loan' account and at least 2 months of balance history showing a steady decrease in principal.",
          textAlign: TextAlign.center,
        ),
      ),
      data: (seriesList) {
        if (seriesList == null || seriesList.isEmpty) {
          return const SizedBox.shrink();
        }

        final List<SproutChartSeries> chartSeries = seriesList.map((series) {
          final Map<DateTime, double> entries = {};
          for (final dp in series.dataPoints) {
            entries[dp.date] = dp.value.abs().toDouble();
          }
          final processedChartData = LineChartDataProcessor.prepareChartData(entries);
          return SproutChartSeries(
            label: series.accountName,
            data: processedChartData,
            config: LineSeriesConfig(
              usePositiveNegativeColors: false,
              color: series.color.toColor,
              showArea: true,
              width: 3.0,
              showInTooltip: true,
            ),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SproutLineChart(
                series: chartSeries,
                chartRange: ChartRangeEnum.allTime,
                header: header,
                showYAxis: true,
                showXAxis: true,
                showGrid: true,
                showLegend: false,
                formatYAxis: (value) => formatter.format(value, compact: true),
                formatValue: (value) => formatter.format(value),
              ),
            ),
            _PayoffSummary(
              seriesList: seriesList,
              renderPayment: true,
            ),
          ],
        );
      },
    );
  }
}

/// Renders payoff date and monthly payment summary cards for each loan series
class _PayoffSummary extends ConsumerWidget {
  final List<LoanAmortizationSeries> seriesList;
  final bool renderPayment;

  const _PayoffSummary({required this.seriesList, required this.renderPayment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMMd();
    final formatter = ref.watch(currencyFormatterProvider);

    // Sort series by date so soonest payoff comes first
    final sortedSeries = List<LoanAmortizationSeries>.from(seriesList)
      ..sort((a, b) {
        final dateA = a.dataPoints.isNotEmpty ? a.dataPoints.last.date : DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.dataPoints.isNotEmpty ? b.dataPoints.last.date : DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });

    // Build card list items
    final cards = sortedSeries.map((series) {
      final color = series.color.toColor;
      final DateTime? payoffDate = series.dataPoints.isNotEmpty ? series.dataPoints.last.date : null;
      final String formattedDate = payoffDate != null ? dateFormat.format(payoffDate) : 'N/A';
      final String formattedPayment = formatter.format(series.monthlyPayment.abs());

      return Container(
        constraints: const BoxConstraints(minWidth: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  series.accountName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      formattedDate,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (renderPayment)
                      Text(
                        '$formattedPayment/mo',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: cards,
              ),
            ),
          ),
        );
      },
    );
  }
}
