import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/widgets/accounts.dart';
import 'package:sprout/cash-flow/widgets/cash_flow_pie_chart.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/net-worth/widgets/overview.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/category_pie_chart.dart';
import 'package:sprout/transaction/widgets/overview.dart';
import 'package:sprout/user/user_config_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends AutoUpdateState<HomePage> {
  /// If we've checked with the user config and already set the default range.
  bool hasSetDefault = false;

  @override
  late Future<dynamic> Function(bool showLoaders) loadData = (showLoaders) async {};

  @override
  Widget build(BuildContext context) {
    return Consumer4<UserConfigProvider, CategoryProvider, TransactionProvider, ConfigProvider>(
      builder: (context, userConfigProvider, catProvider, transactionProvider, configProvider, child) {
        final theme = Theme.of(context);
        final chartRange = userConfigProvider.userDefaultChartRange;
        final catStats = catProvider.categoryStats?.categoryCount;

        final recentTransactionsCount = 10;
        // Handle case where there are fewer transactions than recentTransactionsCount
        final recentTransactions = transactionProvider.transactions.length < recentTransactionsCount
            ? transactionProvider.transactions
            : transactionProvider.transactions.sublist(0, recentTransactionsCount);

        final recentTransactionsDiff = recentTransactions.fold(0.0, (prev, element) => prev + element.amount);

        List<HomeNotification> notifications = [];

        // Check if a sync hasn't ran recently
        final lastSync = configProvider.config?.lastSchedulerRun;
        if (lastSync != null && (!lastSync.time.isSameDay(DateTime.now()) || lastSync.status == "in-progress")) {
          notifications.add(
            HomeNotification(
              "An account sync has not yet ran today",
              theme.colorScheme.error,
              theme.colorScheme.onError,
              icon: Icons.sync,
            ),
          );
        }

        // Check if we have uncategorized transactions so the user can deal with those
        if (catStats != null && catStats.containsKey("Unknown") && catStats["Unknown"] != 0) {
          final unknownCatCount = catStats["Unknown"];
          notifications.add(
            HomeNotification(
              "You have ${formatNumber(unknownCatCount)} uncategorized transactions",
              theme.colorScheme.primary,
              theme.colorScheme.onPrimary,
              icon: Icons.category,
              onClick: () {
                SproutNavigator.redirect("transactions", queryParameters: {'cat': "unknown"});
              },
            ),
          );
        }

        // Determine the layout structure based on desktop or mobile
        return SproutLayoutBuilder((isDesktop, context, constraints) {
          final notificationWidgets = notifications.map((n) {
            return SproutCard(
              bgColor: n.bgColor,
              child: Padding(
                padding: EdgeInsetsGeometry.all(12),
                child: InkWell(
                  onTap: n.onClick,
                  child: Row(
                    spacing: 8,
                    children: [
                      if (n.icon != null) Icon(n.icon, color: n.color),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [Text(n.message, style: TextStyle(color: n.color, fontSize: 16))],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList();

          final netWorthWidget = NetWorthOverviewWidget(
            showCard: true,
            selectedChartRange: chartRange,
            onRangeSelected: (value) {
              userConfigProvider.updateChartRange(value);
            },
            chartHeight: 275,
          );

          final accountsWidget = SproutCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.directional(start: 12, top: 4, bottom: 4),
                  child: Text(
                    "Accounts",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.start,
                  ),
                ),
                const Divider(height: 1),
                AccountsWidget(allowCollapse: true, netWorthPeriod: chartRange, applyCard: false),
              ],
            ),
          );

          final transactionsWidget = ConstrainedBox(
            constraints: BoxConstraints(minHeight: 140, maxHeight: 505),
            child: SizedBox(
              height: 65 + (recentTransactions.length * 65),
              child: SproutCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Recent $recentTransactionsCount Transactions",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),

                          /// Total value change
                          Text(
                            getFormattedCurrency(recentTransactionsDiff),
                            style: TextStyle(color: getBalanceColor(recentTransactionsDiff, theme)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    TransactionsOverview(
                      focusCount: recentTransactionsCount,
                      allowFiltering: false,
                      renderHeader: false,
                      allowLoadingMore: false,
                      showBackToTop: false,
                      separateByDate: false,
                    ),
                  ],
                ),
              ),
            ),
          );

          final pieWidgets = Row(
            children: [
              Expanded(child: CategoryPieChart(showLegend: isDesktop)),
              Expanded(child: CashFlowPieChart(DateTime.now())),
            ],
          );

          if (isDesktop) {
            return Column(
              children: [
                if (notifications.isNotEmpty) Column(children: notificationWidgets),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(spacing: 4, children: [netWorthWidget, accountsWidget])),
                    Expanded(child: Column(spacing: 4, children: [pieWidgets, transactionsWidget])),
                  ],
                ),
              ],
            );
          }

          // Mobile layout
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: <Widget>[
              if (notifications.isNotEmpty) Column(children: notificationWidgets),
              netWorthWidget,
              accountsWidget,
              transactionsWidget,
              pieWidgets,
            ],
          );
        });
      },
    );
  }
}
