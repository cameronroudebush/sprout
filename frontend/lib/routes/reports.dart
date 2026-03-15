import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_pie_chart.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_selector.dart';
import 'package:sprout/cash-flow/widgets/sankey_by_month.dart';
import 'package:sprout/category/widgets/category_pie_chart.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/combo.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/theme/helpers.dart';

/// This page gives the user the ability to track habits over time and generate more useful data reports based on them
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late DateTime _selectedDate;
  CashFlowView _currentView = CashFlowView.monthly;

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

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ThemeHelpers.maxDesktopSize),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _buildSpendingTrend(),
              const Divider(indent: 16, endIndent: 16),
              _buildTimeFrameSection(),
              _buildDetailedAnalysis(theme),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the last spending trend
  Widget _buildSpendingTrend() {
    final spendingAsync = ref.watch(monthlySpendingProvider());

    return spendingAsync.when(
      loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Center(child: Text("Error loading trend: $err")),
      data: (spending) {
        if (spending == null) return const SizedBox.shrink();
        return SizedBox(
          height: 250,
          child: SproutCard(
            child: ComboChart(
              spending,
              title: "Spending Trend",
              onNodeTap: (node) => NavigationProvider.redirectToCatFilter(ref, node, navigateOnUnknown: true),
            ),
          ),
        );
      },
    );
  }

  /// The selector for the detailed reports below
  Widget _buildTimeFrameSection() {
    return SproutCard(
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
        },
        onMonthIncrementChanged: _changeMonth,
        onYearChanged: _changeYear,
      ),
    );
  }

  /// Detailed break-down (Pie Charts and Sankey)
  Widget _buildDetailedAnalysis(ThemeData theme) {
    final month = _currentView == CashFlowView.monthly ? _selectedDate.month : null;
    final year = _selectedDate.year;
    final dateForCharts = DateTime(year, month ?? 1);

    return Column(
      spacing: 4,
      children: [
        // Pie Charts Row/Column
        SproutLayoutBuilder((isDesktop, context, constraints) {
          final charts = [
            Expanded(
              flex: isDesktop ? 1 : 0,
              child: CashFlowPieChart(dateForCharts, view: _currentView, height: 200, showSubheader: true),
            ),
            Expanded(
              flex: isDesktop ? 1 : 0,
              child: CategoryPieChart(dateForCharts, view: _currentView, height: 200, showSubheader: true),
            ),
          ];

          return isDesktop
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: charts)
              : Column(spacing: 4, children: charts.map((e) => e.child).toList());
        }),

        // Sankey Flow
        _buildSankeySection(theme, year, month),
      ],
    );
  }

  /// Builds the sankey data for rendering
  Widget _buildSankeySection(ThemeData theme, int year, int? month) {
    final sankeyAsync = ref.watch(sankeyDataProvider(year: year, month: month));

    return sankeyAsync.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (data) => SproutCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4,
            children: [
              Text(
                "Cash Flow Distribution",
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 600, child: SankeyByMonth(DateTime(year, month ?? 1), view: _currentView)),
            ],
          ),
        ),
      ),
    );
  }
}
