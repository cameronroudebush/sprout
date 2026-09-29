import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_amortization.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_pie_chart.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_sankey.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_selector.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_trend.dart';
import 'package:sprout/cash-flow/widgets/spending_compare.dart';
import 'package:sprout/category/widgets/category_pie_chart.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/tab_selector.dart';

/// This page gives the user the ability to track habits over time and generate more useful data reports based on them
class ReportsPage extends ConsumerStatefulWidget {
  /// Report destinations shown in the mobile selector.
  static const reportTabs = <SproutTabOption<String>>[
    SproutTabOption(value: 'sankey', label: 'Sankey'),
    SproutTabOption(value: 'trend', label: 'Cash Flow'),
    SproutTabOption(value: 'debt', label: 'Loan Projections'),
    SproutTabOption(value: 'pie', label: 'Pie'),
    SproutTabOption(value: 'spending', label: 'Spending'),
  ];

  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTime _selectedDateFromRoute(
    BuildContext context,
    CashFlowView view,
  ) {
    final now = DateTime.now();
    final yearParameter = NavigationProvider.queryParameter(context, 'year');
    final year = int.tryParse(yearParameter ?? '') ?? now.year;
    if (view == CashFlowView.yearly) return DateTime(year, 2, 0);

    final monthParameter = NavigationProvider.queryParameter(context, 'month');
    final defaultMonth = yearParameter == null ? now.month : 1;
    final month = int.tryParse(monthParameter ?? '') ?? defaultMonth;
    if (month < 1 || month > 12) return DateTime(now.year, now.month, 1);
    return DateTime(year, month, 1);
  }

  void _changeMonth(DateTime selectedDate, int monthIncrement) {
    final selectedMonth =
        DateTime(selectedDate.year, selectedDate.month + monthIncrement, 1);
    NavigationProvider.updateQueryParameters(context, {
      'year': selectedMonth.year.toString(),
      'month': selectedMonth.month.toString(),
    });
  }

  void _changeYear(int year) {
    NavigationProvider.updateQueryParameters(context, {
      'year': year.toString(),
      'month': null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestedReport =
        NavigationProvider.queryParameter(context, 'report');
    final reportView =
        ReportsPage.reportTabs.any((tab) => tab.value == requestedReport)
            ? requestedReport!
            : 'sankey';
    final currentView = CashFlowView.values.firstWhere(
      (view) => view.name == NavigationProvider.queryParameter(context, 'view'),
      orElse: () => CashFlowView.monthly,
    );
    final selectedDate = _selectedDateFromRoute(context, currentView);

    return SproutRouteWrapper(
      size: SproutRouteSize.large,
      child: SproutTabbedLayout(
        tabs: ReportsPage.reportTabs,
        selected: reportView,
        dropdownTooltip: 'Select report',
        dropdownHeading: 'Report Type',
        dropdownIcon: Icons.bar_chart_rounded,
        onSelected: (view) => NavigationProvider.updateQueryParameters(
          context,
          {'report': view},
        ),
        child: SproutLayoutBuilder(
          (isDesktop, context, constraints) => Padding(
            padding: EdgeInsets.only(
              bottom: isDesktop
                  ? 0
                  : SproutTabbedLayout.mobileNavigationScrollInset,
            ),
            child: SproutCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_usesPeriod(reportView)) ...[
                    CashFlowSelector(
                      currentView: currentView,
                      selectedDate: selectedDate,
                      onViewChanged: (view) {
                        if (view == CashFlowView.monthly) {
                          final now = DateTime.now();
                          NavigationProvider.updateQueryParameters(context, {
                            'view': view.name,
                            'year': now.year.toString(),
                            'month': now.month.toString(),
                          });
                        } else {
                          NavigationProvider.updateQueryParameters(context, {
                            'view': view.name,
                            'year': selectedDate.year.toString(),
                            'month': null,
                          });
                        }
                      },
                      onMonthIncrementChanged: (increment) =>
                          _changeMonth(selectedDate, increment),
                      onYearChanged: _changeYear,
                    ),
                    const Divider(),
                  ],
                  Expanded(
                    child: _buildActiveReportView(
                      reportView,
                      currentView,
                      selectedDate,
                      isDesktop,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Whether [view] needs monthly/yearly date controls.
  bool _usesPeriod(String view) =>
      view == 'sankey' || view == 'pie' || view == 'spending';

  /// Builds selected report chart to fill the available content area.
  Widget _buildActiveReportView(
    String reportView,
    CashFlowView currentView,
    DateTime selectedDate,
    bool isDesktop,
  ) {
    switch (reportView) {
      case 'trend':
        return CashFlowTrendChart(barCount: isDesktop ? 10 : 6);
      case 'debt':
        return const CashFlowLoanAmortizationChart();
      case 'sankey':
        return CashFlowSankeyChart(
          selectedDate: selectedDate,
          view: currentView,
        );
      case 'spending':
        return SpendingCompareChart(
          view: currentView,
          selectedDate: selectedDate,
        );
      case 'pie':
        final month =
            currentView == CashFlowView.monthly ? selectedDate.month : null;
        final dateForCharts = DateTime(selectedDate.year, month ?? 1);
        final categoryChart = CategoryPieChart(
          dateForCharts,
          view: currentView,
          legendPosition: SproutChartLegendPosition.left,
          header: const SproutChartHeader(title: 'Expense Categories'),
        );
        final cashFlowChart = CashFlowPieChart(
          dateForCharts,
          view: currentView,
          showSubheader: true,
          legendPosition: SproutChartLegendPosition.none,
          header: const SproutChartHeader(title: 'Cash Flow'),
        );

        return isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(child: categoryChart),
                  Expanded(child: cashFlowChart),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Expanded(child: categoryChart),
                  Expanded(child: cashFlowChart),
                ],
              );
      default:
        return CashFlowSankeyChart(
          selectedDate: selectedDate,
          view: currentView,
        );
    }
  }
}
