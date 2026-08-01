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
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/layout.dart';

enum MacroChartType { trend, debt }

enum PeriodChartType { sankey, pie, spending }

/// This page gives the user the ability to track habits over time and generate more useful data reports based on them
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late DateTime _selectedDate;
  CashFlowView _currentView = CashFlowView.monthly;

  MacroChartType _currentMacroChart = MacroChartType.trend;
  PeriodChartType _currentPeriodChart = PeriodChartType.sankey;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month + 1, 0);
  }

  /// Changes the month based on the given increment
  void _changeMonth(int monthIncrement) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + monthIncrement + 1, 0);
    });
  }

  /// Changes the year to the exact given year
  void _changeYear(int year) {
    setState(() {
      _selectedDate = DateTime(year, 2, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: SproutRouteWrapper(
        size: SproutRouteSize.large,
        child: SproutLayoutBuilder(
          (isDesktop, context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 0,
              children: [
                _buildMacroSection(theme, isDesktop),
                _buildPeriodSection(theme, isDesktop),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Long-term Workspace (No Date Selector)
  Widget _buildMacroSection(ThemeData theme, bool isDesktop) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<MacroChartType>(
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment(
                  value: MacroChartType.trend,
                  label: Text('Cash Flow Trend'),
                  icon: Icon(Icons.bar_chart),
                ),
                ButtonSegment(
                  value: MacroChartType.debt,
                  label: Text('Loan Projections'),
                  icon: Icon(Icons.account_balance_wallet),
                ),
              ],
              selected: {_currentMacroChart},
              onSelectionChanged: (Set<MacroChartType> newSelection) {
                setState(() {
                  _currentMacroChart = newSelection.first;
                });
              },
            ),
            // Render active macro chart
            if (_currentMacroChart == MacroChartType.trend)
              SizedBox(
                height: 250,
                child: CashFlowTrendChart(
                  barCount: isDesktop ? 10 : 6,
                ),
              )
            else
              SizedBox(
                height: 250,
                child: const CashFlowLoanAmortizationChart(),
              ),
          ],
        ),
      ),
    );
  }

  /// Monthly/Yearly Workspace with Switcher
  Widget _buildPeriodSection(ThemeData theme, bool isDesktop) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CashFlowSelector(
              currentView: _currentView,
              selectedDate: _selectedDate,
              onViewChanged: (view) {
                setState(() {
                  _currentView = view;
                  if (view == CashFlowView.monthly) {
                    final now = DateTime.now();
                    _selectedDate = DateTime(now.year, now.month + 1, 0);
                  }
                });
              },
              onMonthIncrementChanged: _changeMonth,
              onYearChanged: _changeYear,
            ),
            const Divider(),

            SegmentedButton<PeriodChartType>(
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment(
                  value: PeriodChartType.sankey,
                  label: Text('Sankey'),
                  icon: Icon(Icons.account_tree_outlined),
                ),
                ButtonSegment(
                  value: PeriodChartType.pie,
                  label: Text('Pie'),
                  icon: Icon(Icons.pie_chart_outline),
                ),
                ButtonSegment(
                  value: PeriodChartType.spending,
                  label: Text('Line'),
                  icon: Icon(Icons.trending_up),
                ),
              ],
              selected: {_currentPeriodChart},
              onSelectionChanged: (Set<PeriodChartType> newSelection) {
                setState(() {
                  _currentPeriodChart = newSelection.first;
                });
              },
            ),
            // Render the selected period chart
            _buildActivePeriodChart(theme, isDesktop),
          ],
        ),
      ),
    );
  }

  /// Renders only the period chart the user has selected
  Widget _buildActivePeriodChart(ThemeData theme, bool isDesktop) {
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;
    final year = _selectedDate.year;
    final dateForCharts = DateTime(year, month ?? 1);

    switch (_currentPeriodChart) {
      case PeriodChartType.sankey:
        return CashFlowSankeyChart(
          selectedDate: _selectedDate,
          view: _currentView,
        );

      case PeriodChartType.spending:
        return SizedBox(
          height: isDesktop ? 350 : 300,
          child: SpendingCompareChart(
            view: _currentView,
            selectedDate: _selectedDate,
          ),
        );

      case PeriodChartType.pie:
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(
                child: SizedBox(
                  height: 300,
                  child: CategoryPieChart(
                    dateForCharts,
                    view: _currentView,
                    legendPosition: SproutChartLegendPosition.left,
                    header: const SproutChartHeader(
                      title: "Expense Categories",
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 300,
                  child: CashFlowPieChart(
                    dateForCharts,
                    view: _currentView,
                    showSubheader: true,
                    legendPosition: SproutChartLegendPosition.none,
                    header: const SproutChartHeader(
                      title: "Cash Flow",
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          spacing: 16,
          children: [
            SizedBox(
              height: 300,
              child: CategoryPieChart(
                dateForCharts,
                view: _currentView,
                legendPosition: SproutChartLegendPosition.left,
                header: const SproutChartHeader(
                  title: "Expense Categories",
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: CashFlowPieChart(
                dateForCharts,
                view: _currentView,
                showSubheader: true,
                legendPosition: SproutChartLegendPosition.none,
                header: const SproutChartHeader(
                  title: "Cash Flow",
                ),
              ),
            ),
          ],
        );
    }
  }
}
