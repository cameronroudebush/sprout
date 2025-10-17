import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/provider.dart';
import 'package:sprout/cash-flow/widgets/sankey_by_month.dart';
import 'package:sprout/cash-flow/widgets/stats_by_month.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';

/// Renders the cash-flow page so the user can see where their money is going based on selected month
class CashFlowOverview extends StatefulWidget {
  const CashFlowOverview({super.key});

  @override
  State<CashFlowOverview> createState() => _CashFlowOverviewState();
}

class _CashFlowOverviewState extends State<CashFlowOverview> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month + 1, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  /// Fetches data we need for these displays
  void _fetchData() {
    final provider = ServiceLocator.get<CashFlowProvider>();
    if (provider.getSankeyData(_selectedDate.year, _selectedDate.month) == null) {
      context.read<CashFlowProvider>().getSankey(_selectedDate.year, _selectedDate.month);
    }
    if (provider.getStatsData(_selectedDate.year, _selectedDate.month) == null) {
      context.read<CashFlowProvider>().getStats(_selectedDate.year, _selectedDate.month);
    }
  }

  void _changeMonth(int monthIncrement) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + monthIncrement + 1, 0);
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        // Month selector
        SproutCard(child: _buildMonthSelector()),
        // Stats
        SproutCard(child: StatsByMonth(_selectedDate)),
        // Sankey
        SproutCard(
          child: Padding(padding: EdgeInsetsGeometry.all(12), child: SankeyFlowByMonth(_selectedDate)),
        ),
      ],
    );
  }

  /// Builds a month selector to allow us to decide what month of data we currently want
  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SproutTooltip(
            message: "Previous Month",
            child: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
          ),
          SizedBox(
            width: 250,
            child: Center(
              child: TextWidget(
                referenceSize: 1.25,
                text: DateFormat('MMMM yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SproutTooltip(
            message: "Next Month",
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _selectedDate.isBefore(currentMonthEnd) ? () => _changeMonth(1) : null,
            ),
          ),
          SproutTooltip(
            message: "This Month",
            child: IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_right),
              onPressed: _selectedDate.month != currentMonthEnd.month || _selectedDate.year != currentMonthEnd.year
                  ? () => _changeMonth(currentMonthEnd.month - _selectedDate.month)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
