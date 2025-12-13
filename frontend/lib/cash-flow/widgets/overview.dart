import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_pie_chart.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_selector.dart';
import 'package:sprout/cash-flow/widgets/sankey_by_month.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/scroll.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/core/widgets/tabs.dart';
import 'package:sprout/transaction/widgets/category_pie_chart.dart';

/// Renders the cash-flow page so the user can see where their money is going based on selected month
class CashFlowOverview extends StatefulWidget {
  const CashFlowOverview({super.key});

  @override
  State<CashFlowOverview> createState() => _CashFlowOverviewState();
}

class _CashFlowOverviewState extends StateTracker<CashFlowOverview> {
  late DateTime _selectedDate;

  @override
  Map<dynamic, DataRequest> get requests {
    final date = _selectedDate;
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;
    final cashFlowProvider = context.read<CashFlowProvider>();

    return {
      'sankey': DataRequest<CashFlowProvider, dynamic>(
        provider: cashFlowProvider,
        onLoad: (p, force) => p.getSankey(date.year, month),
        getFromProvider: (p) => p.getSankeyData(date.year, month),
      ),
      'stats': DataRequest<CashFlowProvider, dynamic>(
        provider: cashFlowProvider,
        onLoad: (p, force) => p.getStats(date.year, month),
        getFromProvider: (p) => p.getStatsData(date.year, month),
      ),
      'catStats': DataRequest<CategoryProvider, dynamic>(
        provider: ServiceLocator.get<CategoryProvider>(),
        onLoad: (p, force) => p.loadCategoryStats(date.year, month),
        getFromProvider: (p) => p.getStatsData(date.year, month),
      ),
    };
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month + 1, 0);
  }

  CashFlowView _currentView = CashFlowView.monthly;

  void _changeMonth(int monthIncrement) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + monthIncrement + 1, 0);
    });
    loadData();
  }

  void _changeYear(int year) {
    setState(() {
      // When changing year, we can default to January of that year.
      _selectedDate = DateTime(year, 2, 0);
    });
    loadData();
  }

  Widget _buildStats() {
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;

    return SproutScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Render some pie charts for more info
          SproutLayoutBuilder((isDesktop, context, constraints) {
            final dateForCharts = DateTime(_selectedDate.year, month ?? 1);
            final pieCharts = [
              Expanded(
                child: CashFlowPieChart(
                  dateForCharts,
                  view: _currentView,
                  height: isDesktop ? 450 : 250,
                  showSubheader: false,
                ),
              ),
              Expanded(
                child: CategoryPieChart(
                  dateForCharts,
                  view: _currentView,
                  height: isDesktop ? 450 : 250,
                  showSubheader: false,
                ),
              ),
            ];
            if (isDesktop) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: pieCharts);
            }
            return Column(children: pieCharts.map((e) => e.child).toList());
          }),
        ],
      ),
    );
  }

  Widget _buildSankey() {
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;
    final dateForSankey = DateTime(_selectedDate.year, month ?? 1);
    return SproutCard(
      child: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: SankeyFlowByMonth(dateForSankey, view: _currentView),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabNames = ["Stats", "Sankey"];
    final tabContent = [_buildStats(), _buildSankey()];
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.maxDesktopSize),
        child: Column(
          children: [
            // Selector
            SproutCard(
              child: CashFlowSelector(
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
                  loadData();
                },
                onMonthIncrementChanged: _changeMonth,
                onYearChanged: _changeYear,
              ),
            ),
            // Tab view
            Expanded(child: ScrollableTabsWidget(tabNames, tabContent)),
          ],
        ),
      ),
    );
  }
}
