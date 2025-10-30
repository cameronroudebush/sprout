import 'package:flutter/material.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_pie_chart.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_selector.dart';
import 'package:sprout/cash-flow/widgets/sankey_by_month.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/scroll.dart';
import 'package:sprout/core/widgets/tabs.dart';
import 'package:sprout/transaction/widgets/category_pie_chart.dart';

/// Renders the cash-flow page so the user can see where their money is going based on selected month
class CashFlowOverview extends StatefulWidget {
  const CashFlowOverview({super.key});

  @override
  State<CashFlowOverview> createState() => _CashFlowOverviewState();
}

enum CashFlowView { monthly, yearly }

class _CashFlowOverviewState extends AutoUpdateState<CashFlowOverview> {
  late DateTime _selectedDate;

  @override
  late Future<dynamic> Function(bool showLoaders) loadData = (showLoaders) => _fetchData();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month + 1, 0);
  }

  CashFlowView _currentView = CashFlowView.monthly;

  /// Fetches data we need for these displays
  Future<void> _fetchData() async {
    final cashFlowProvider = ServiceLocator.get<CashFlowProvider>();
    final categoryProvider = ServiceLocator.get<CategoryProvider>();
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;

    cashFlowProvider.setLoadingStatus(true);
    categoryProvider.setLoadingStatus(true);

    if (cashFlowProvider.getSankeyData(_selectedDate.year, month) == null) {
      cashFlowProvider.getSankey(_selectedDate.year, month);
    }
    if (cashFlowProvider.getStatsData(_selectedDate.year, month) == null) {
      cashFlowProvider.getStats(_selectedDate.year, month);
    }
    if (categoryProvider.getStatsData(_selectedDate.year, month) == null) {
      categoryProvider.loadCategoryStats(_selectedDate.year, month);
    }
    cashFlowProvider.setLoadingStatus(false);
    categoryProvider.setLoadingStatus(false);
  }

  void _changeMonth(int monthIncrement) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + monthIncrement + 1, 0);
    });
    _fetchData();
  }

  void _changeYear(int year) {
    setState(() {
      // When changing year, we can default to January of that year.
      _selectedDate = DateTime(year, 2, 0);
    });
    _fetchData();
  }

  Widget _buildStats() {
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;

    return SproutScrollView(
      padding: EdgeInsets.zero,
      child: Expanded(
        child: Column(
          children: [
            // Render some pie charts for more info
            SproutLayoutBuilder((isDesktop, context, constraints) {
              final dateForCharts = DateTime(_selectedDate.year, month ?? 1);
              final pieCharts = [
                Expanded(
                  child: CashFlowPieChart(dateForCharts, view: _currentView, height: isDesktop ? 450 : 200),
                ),
                Expanded(
                  child: CategoryPieChart(dateForCharts, view: _currentView, height: isDesktop ? 450 : 200),
                ),
              ];
              if (isDesktop) {
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: pieCharts);
              }
              return Column(children: pieCharts.map((e) => e.child).toList());
            }),
          ],
        ),
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
                  _fetchData();
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
