import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_pie_chart.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_sankey.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_selector.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_trend.dart';
import 'package:sprout/category/widgets/category_pie_chart.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';
import 'package:sprout/shared/widgets/layout.dart';

enum DetailChartType { pie, sankey }

/// This page gives the user the ability to track habits over time and generate more useful data reports based on them
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late DateTime _selectedDate;
  CashFlowView _currentView = CashFlowView.monthly;
  DetailChartType _currentDetailChart = DetailChartType.sankey;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CashFlowTrendChart(height: 200),
            _buildMicroDetailSection(theme),
          ],
        ),
      ),
    );
  }

  /// Monthly Workspace with Switcher
  Widget _buildMicroDetailSection(ThemeData theme) {
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

            // The View Switcher
            SegmentedButton<DetailChartType>(
              segments: const [
                ButtonSegment(
                  value: DetailChartType.sankey,
                  label: Text('Sankey'),
                  icon: Icon(Icons.account_tree_outlined),
                ),
                ButtonSegment(
                  value: DetailChartType.pie,
                  label: Text('Pie'),
                  icon: Icon(Icons.pie_chart_outline),
                ),
              ],
              selected: {_currentDetailChart},
              onSelectionChanged: (Set<DetailChartType> newSelection) {
                setState(() {
                  _currentDetailChart = newSelection.first;
                });
              },
            ),

            // Render the selected chart type
            _buildActiveDetailChart(theme),
          ],
        ),
      ),
    );
  }

  /// Renders only the chart the user has selected
  Widget _buildActiveDetailChart(ThemeData theme) {
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;
    final year = _selectedDate.year;
    final dateForCharts = DateTime(year, month ?? 1);

    return SproutLayoutBuilder(
      (isDesktop, context, constraints) {
        switch (_currentDetailChart) {
          case DetailChartType.sankey:
            return CashFlowSankeyChart(
              selectedDate: _selectedDate,
              view: _currentView,
            );
          case DetailChartType.pie:
            return Column(
              spacing: 0,
              children: [
                CategoryPieChart(
                  dateForCharts,
                  view: _currentView,
                  height: isDesktop ? 600 : 300,
                  showSubheader: true,
                  legendPosition: PieLegendPosition.left,
                ),
                CashFlowPieChart(
                  dateForCharts,
                  view: _currentView,
                  height: isDesktop ? 600 : 300,
                  showSubheader: true,
                  legendPosition: PieLegendPosition.none,
                ),
              ],
            );
        }
      },
    );
  }
}
