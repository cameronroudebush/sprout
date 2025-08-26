import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/scroll.dart';
import 'package:sprout/transaction/widgets/cash_flow_pie_chart.dart';
import 'package:sprout/transaction/widgets/category_pie_chart.dart';
import 'package:sprout/transaction/widgets/summary.dart';
import 'package:sprout/transaction/widgets/transactions.dart';

class TransactionsOverviewPage extends StatelessWidget {
  const TransactionsOverviewPage({super.key});

  Widget _getMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 150, child: TransactionSummaryCard()),
        SizedBox(
          height: 315,
          child: Row(
            children: [
              Expanded(child: CashFlowPieChart(showLegend: false)),
              Expanded(child: CategoryPieChart(showLegend: false)),
            ],
          ),
        ),
        TransactionsCard(rowsPerPage: 12, title: "All Transactions"),
      ],
    );
  }

  Widget _getDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 150, child: TransactionSummaryCard()),
        SizedBox(
          height: 315,
          child: Row(
            children: [
              Expanded(child: CashFlowPieChart()),
              Expanded(child: CategoryPieChart()),
            ],
          ),
        ),
        TransactionsCard(rowsPerPage: 12, title: "All Transactions"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SproutScrollView(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            return _getMobileLayout(context);
          } else {
            return _getDesktopLayout(context);
          }
        },
      ),
    );
  }
}
