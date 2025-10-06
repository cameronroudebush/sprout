import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/accounts.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/widgets/overview.dart';
import 'package:sprout/transaction/overview.dart';
import 'package:sprout/transaction/provider.dart';
import 'package:sprout/user/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// If we've checked with the user config and already set the default range.
  bool hasSetDefault = false;

  @override
  Widget build(BuildContext context) {
    return Consumer4<UserProvider, CategoryProvider, TransactionProvider, ConfigProvider>(
      builder: (context, provider, catProvider, transactionProvider, configProvider, child) {
        final theme = Theme.of(context);
        final chartRange = provider.userDefaultChartRange;
        final catStats = catProvider.categoryStats?.categoryCount;
        final transactionsDay = DateTime.now();
        final todaysTransactions = transactionProvider.transactions.where((t) => t.posted.isSameDay(transactionsDay));
        final todaysTransactionsDiff = todaysTransactions.fold(0.0, (prev, element) => prev + element.amount);

        List<HomeNotification> notifications = [];

        // Check if a sync hasn't ran recently
        final lastSync = configProvider.config?.lastSchedulerRun;
        if (lastSync != null && (!lastSync.time!.isSameDay(DateTime.now()) || lastSync.status == "in-progress")) {
          notifications.add(
            HomeNotification(
              "An account sync has not yet ran today",
              theme.colorScheme.error,
              theme.colorScheme.onError,
              icon: Icons.sync,
            ),
          );
        }

        // Check if we have uncategorized transactions so the user can deal wit hthose
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: <Widget>[
            // Render notifications available
            if (notifications.isNotEmpty)
              Column(
                children: notifications.map((n) {
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
                                children: [
                                  TextWidget(
                                    text: n.message,
                                    referenceSize: 1.15,
                                    style: TextStyle(color: n.color),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            // Net Worth Section
            NetWorthOverviewWidget(
              showCard: true,
              selectedChartRange: chartRange,
              onRangeSelected: (value) {
                provider.updateChartRange(value);
              },
            ),
            // Accounts Section
            SproutCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.directional(start: 12, top: 4, bottom: 4),
                    child: TextWidget(
                      referenceSize: 1.25,
                      text: "Accounts",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const Divider(height: 1),
                  AccountsWidget(allowCollapse: true, netWorthPeriod: chartRange, applyCard: false),
                ],
              ),
            ),

            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 140, maxHeight: 400),
              child: SizedBox(
                height: 65 + (todaysTransactions.length * 70),
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
                            TextWidget(
                              text: "Today's Transactions",
                              referenceSize: 1.25,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            /// Total value change
                            TextWidget(
                              text: getFormattedCurrency(todaysTransactionsDiff),
                              style: TextStyle(color: getBalanceColor(todaysTransactionsDiff, theme)),
                              referenceSize: 1.15,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      TransactionsOverview(focusDate: transactionsDay, allowFiltering: false, renderHeader: false),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
