import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/accounts.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/widgets/overview.dart';
import 'package:sprout/transaction/widgets/transactions.dart';
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
    return Consumer2<UserProvider, CategoryProvider>(
      builder: (context, provider, catProvider, child) {
        final theme = Theme.of(context).colorScheme;
        final chartRange = provider.userDefaultChartRange;
        final lastTransactionCount = 10;
        final catStats = catProvider.categoryStats?.categoryCount;

        List<HomeNotification> notifications = [];

        if (catStats != null && catStats.containsKey("Unknown") && catStats["Unknown"] != 0) {
          final unknownCatCount = catStats["Unknown"];
          notifications.add(
            HomeNotification(
              "You have ${formatNumber(unknownCatCount)} un-categorized transactions",
              theme.primary,
              theme.onPrimary,
              icon: Icons.category,
              onClick: () => SproutNavigator.redirect("transactions"),
            ),
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 0,
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
                          referenceSize: 1.5,
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
                // Recent Transactions
                SproutCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TransactionsCard(
                        applyCard: false,
                        allowPagination: false,
                        rowsPerPage: lastTransactionCount,
                        allowSearch: false,
                        title: "Recent $lastTransactionCount Transactions",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
