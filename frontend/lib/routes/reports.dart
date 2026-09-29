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
        mobileNavigation: _buildMobileReportMenu(context, reportView),
        child: SproutLayoutBuilder(
          (isDesktop, context, constraints) => SproutCard(
            child: Padding(
              padding: const EdgeInsets.all(0),
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

  /// Shows active report in one compact mobile menu instead of listing every view.
  Widget _buildMobileReportMenu(BuildContext context, String selectedReport) {
    final theme = Theme.of(context);
    final selectedTab =
        ReportsPage.reportTabs.firstWhere((tab) => tab.value == selectedReport);

    return PopupMenuButton<String>(
      tooltip: 'Select report',
      position: PopupMenuPosition.over,
      onSelected: (view) => NavigationProvider.updateQueryParameters(
        context,
        {'report': view},
      ),
      itemBuilder: (context) => ReportsPage.reportTabs.map((tab) {
        final isSelected = tab.value == selectedReport;
        return PopupMenuItem<String>(
          value: tab.value,
          child: Row(
            spacing: 8,
            children: [
              Icon(
                isSelected ? Icons.check : Icons.circle_outlined,
                size: 16,
              ),
              Text(tab.label),
            ],
          ),
        );
      }).toList(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          spacing: 8,
          children: [
            Icon(Icons.bar_chart, color: theme.colorScheme.primary, size: 18),
            Expanded(
              child: Text(
                selectedTab.label,
                style: theme.textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_up),
          ],
        ),
      ),
    );
  }

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
